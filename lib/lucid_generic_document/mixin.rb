module LucidGenericDocument
  module Mixin
    def self.included(base)
      base.extend(LucidPropDeclaration::Mixin)
      base.extend(Isomorfeus::Data::GenericClassApi)
      base.include(Isomorfeus::Data::GenericInstanceApi)

      base.instance_exec do
        def _handler_type
          'document'
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
              path = @_store_path + [name]
              result = Redux.fetch_by_path(*path)
              if result
                result
              elsif !@_default_proc
                @_default
              else
                @_default_proc.call(self, name)
              end
            end

            define_method("#{name}=") do |val|
              _validate_attribute(name, val)
              _update_attribute(name, val)
              val
            end
          end
        end

        def initialize(key:, revision: nil, attributes: nil)
          @key = key.to_s
          @class_name = self.class.name
          @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
          @_store_path = [:data_state, @class_name, @key]
          @_changed_store_path = [:data_state, :changed, @class_name, @key]
          @_revision_store_path = [:data_state, :revision, @class_name, @key]
          attributes = {} unless attributes
          attributes.each { |a,v| _validate_attribute(a, v) }
          Isomorfeus.store.dispatch(type: 'DATA_LOAD', data: { @class_name => { @key => attributes },
                                                               changed: { @class_name => { @key => false }},
                                                               revision: { @class_name => { @key => revision }}})
        end

        def _update_attribute(attr_name, attr_val)
          Isomorfeus.store.dispatch(type: 'DATA_LOAD', data: { @class_name => { @key => { attr_name => attr_val }},
                                                               changed: { @class_name => { @key => true }}})
        end

        def _update_attributes(hash)
          Isomorfeus.store.dispatch(type: 'DATA_LOAD', data: { @class_name => { @key => hash},
                                                               changed: { @class_name => { @key => true }}})
        end

        def each(&block)
          raw_attributes = Redux.fetch_by_path(*@_store_path)
          Hash.new(raw_attributes).each(&block)
        end

        def [](name)
          path = @_store_path + [name]
          result = Redux.fetch_by_path(*path)
          return result if result
          nil
        end

        def []=(name, val)
          _validate_attribute(name, val)
          _update_attribute(name, val)
          val
        end

        def to_transport
          raw_hash = Redux.fetch_by_path(*@_store_path)
          hash = raw_hash ? Hash.new(raw_hash) : {}
          hash.merge!(_revision: revision)
          { @class_name => { @key => hash }}
        end
      else # RUBY_ENGINE
        unless base == LucidGenericDocument::Base
          Isomorfeus.add_valid_generic_document_class(base)
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

        def initialize(key:, revision: nil, attributes: nil)
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

        def to_transport
          hash = {}
          self.class.attribute_conditions.each do |attr, options|
            if !options[:server_only] && @_raw_attributes.key?(attr)
              hash[attr.to_s] = @_raw_attributes[attr]
            end
          end
          hash.merge!("_revision" => revision)
          { @class_name => { @key => hash }}
        end
      end # RUBY_ENGINE
    end
  end
end
