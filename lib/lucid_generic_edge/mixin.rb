module LucidGenericEdge
  module Mixin
    def self.included(base)
      base.extend(LucidPropDeclaration::Mixin)
      base.extend(Isomorfeus::Data::GenericClassApi)
      base.include(Isomorfeus::Data::GenericInstanceApi)

      base.instance_exec do
        def _handler_type
          'edge'
        end

        def attribute_conditions
          @attribute_conditions ||= {}
        end

        def valid_attribute?(attr_name, attr_value)
          Isomorfeus::Props::Validator.new(self.name, attr_name, attr_value, attribute_conditions[attr_name]).validate!
        rescue
          false
        end
      end

      def _validate_attribute(attr_name, attr_val)
        Isomorfeus::Props::Validator.new(@class_name, attr_name, attr_val, self.class.attribute_conditions[attr_name]).validate!
      end

      if RUBY_ENGINE == 'opal'
        base.instance_exec do
          def attribute(name, options = {})
            attribute_conditions[name] = options

            define_method(name) do
              _get_attribute(name)
            end

            define_method("#{name}=") do |val|
              _validate_attribute(name, val)
              @_changed_attributes[name] = val
            end
          end
        end

        def initialize(key:, revision: nil, from:, to:, attributes: nil)
          @key = key.to_s
          @class_name = self.class.name
          @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
          @_store_path = [:data_state, @class_name, @key, :attributes]
          @_from_path = [:data_state, @class_name, @key, :from]
          @_to_path = [:data_state, @class_name, @key, :to]
          @_changed_attributes = {}
          @_revision_store_path = [:data_state, :revision, @class_name, @key]
          @_revision = revision ? revision : Redux.fetch_by_path(*@_revision_store_path)
          attributes = {} unless attributes
          attributes.each { |a,v| _validate_attribute(a, v) }
          raw_attributes = Redux.fetch_by_path(*@_store_path)
          if `raw_attributes === null`
            @_changed_attributes = !attributes ? {} : attributes
          elsif raw_attributes && !attributes.nil? && Hash.new(raw_attributes) != attributes
            @_changed_attributes = attributes
          end
          @_changed_from = nil
          @_changes_to = nil
          from = from.to_sid if from.respond_to?(:to_sid)
          to = to.to_sid if to.respond_to?(:to_sid)
          store_from = Redux.fetch_by_path(*@_from_path)
          store_to = Redux.fetch_by_path(*@_to_path)
          @_changed_from = from unless `from == store_from`
          @_changed_to = to unless `to == store_to`
          @_from_instance = nil
          @_to_instance = nil
        end

        def _get_attribute(name)
          return @_changed_attributes[name] if @_changed_attributes.key?(name)
          path = @_store_path + [name]
          result = Redux.fetch_by_path(*path)
          return nil if `result === null`
          result
        end

        def _get_attributes
          raw_attributes = Redux.fetch_by_path(*@_store_path)
          hash = Hash.new(raw_attributes)
          hash.merge!(@_changed_attributes) if @_changed_attributes
          hash
        end

        def changed?
          @_changed_attributes.any?
        end

        def revision
          @_revision
        end

        def each(&block)
          _get_attributes.each(&block)
        end

        def [](name)
          _get_attribute(name)
        end

        def []=(name, val)
          _validate_attribute(name, val)
          @_changed_attributes[name] = val
        end

        def from
          return @_from_instance if @_from_instance
          sid = @_changed_from ? @_changed_from : Redux.fetch_by_path(@_from_path)
          @_from_instance = LucidGenericDocument::Base.document_from_sid(sid)
        end

        def from=(document)
          if document.respond_to?(:to_sid)
            @_changed_from = document.to_sid
            @_from_instance = document
          else
            @_changed_from = document
            @_from_instance = LucidGenericDocument::Base.document_from_sid(document)
          end
        end

        def to
          return @_to_instance if @_to_instance
          sid = @_changed_to ? @_changed_to : Redux.fetch_by_path(@_to_path)
          @_to_instance = LucidGenericDocument::Base.document_from_sid(sid)
        end

        def to=(document)
          if document.respond_to?(:to_sid)
            @_changed_to = document.to_sid
            @_to_instance = document
          else
            @_changed_to = document
            @_to_instance = LucidGenericDocument::Base.document_from_sid(document)
          end
        end

        def to_transport
          { @class_name => { @key => { attributes: _get_attributes,
                                       from: @_changed_from ? @_changed_from : Redux.fetch_by_path(@_from_path),
                                       to: @_changed_to ? @_changed_to : Redux.fetch_by_path(@_to_path),
                                       _revision: revision }}}
        end
      else # RUBY_ENGINE
        unless base == LucidGenericEdge::Base
          Isomorfeus.add_valid_generic_edge_class(base)
          base.prop :pub_sub_client, default: nil
          base.prop :current_user, default: Anonymous.new
        end

        base.instance_exec do
          def attribute(name, options = {})
            attribute_conditions[name] = options

            define_method(name) do
              @_raw_attributes[name]
            end

            define_method("#{name}=") do |val|
              _validate_attribute(name, val)
              @_changed = true
              @_raw_attributes[name] = val
            end
          end
        end

        def initialize(key:, revision: nil, from:, to:, attributes: nil)
          @key = key.to_s
          @_revision = revision
          @_changed = false
          @class_name = self.class.name
          @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
          @_validate_attributes = self.class.attribute_conditions.any?
          attributes = {} unless attributes
          if @_validate_attributes
            attributes.each { |a,v| _validate_attribute(a, v) }
          end
          @_raw_attributes = attributes
          @_changed_from = nil
          @_changes_to = nil
          from = from.to_sid if from.respond_to?(:to_sid)
          to = to.to_sid if to.respond_to?(:to_sid)
          @_raw_from = from
          @_raw_to = to
          @_from_instance = nil
          @_to_instance = nil
        end

        def changed?
          @_changed
        end

        def revision
          @_revision
        end

        def each(&block)
          @_raw_attributes.each(&block)
        end

        def [](name)
          @_raw_attributes[name]
        end

        def []=(name, val)
          _validate_attribute(name, val)
          @_changed = true
          @_raw_attributes[name] = val
        end

        def from
          return @_from_instance if @_from_instance
          sid = @_changed_from ? @_changed_from : @_raw_from
          @_from_instance = LucidGenericDocument::Base.document_from_sid(sid)
        end

        def from=(document)
          if document.respond_to?(:to_sid)
            @_changed_from = document.to_sid
            @_from_instance = document
          else
            @_changed_from = document
            @_from_instance = LucidGenericDocument::Base.document_from_sid(document)
          end
        end

        def to
          return @_to_instance if @_to_instance
          sid = @_changed_to ? @_changed_to : @_raw_to
          @_to_instance = LucidGenericDocument::Base.document_from_sid(sid)
        end

        def to=(document)
          if document.respond_to?(:to_sid)
            @_changed_to = document.to_sid
            @_to_instance = document
          else
            @_changed_to = document
            @_to_instance = LucidGenericDocument::Base.document_from_sid(document)
          end
        end

        def to_transport
          attributes = {}
          self.class.attribute_conditions.each do |attr, options|
            if !options[:server_only] && @_raw_attributes.key?(attr)
              attributes[attr.to_s] = @_raw_attributes[attr]
            end
          end
          { @class_name => { @key => { "attributes" => attributes,
                                       "from" => @_changed_from ? @_changed_from : @_raw_from,
                                       "to" => @_changed_to ? @_changed_to : @_raw_to,
                                       "_revision" => revision }}}
        end
      end # RUBY_ENGINE
    end
  end
end
