module LucidData
  module Edge
    module Mixin
      def self.included(base)
        base.extend(LucidPropDeclaration::Mixin)
        base.extend(Isomorfeus::Data::GenericClassApi)
        base.include(Isomorfeus::Data::GenericInstanceApi)

        base.instance_exec do
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
          raise "No such attribute declared: '#{attr_name}'!" unless self.class.attribute_conditions.key?(attr_name)
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

          def initialize(key:, revision: nil, from: nil, to: nil, attributes: nil, collection: nil)
            @key = key.to_s
            @class_name = self.class.name
            @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
            @_collection = collection
            @_store_path = [:data_state, @class_name, @key, :attributes]
            @_from_path = [:data_state, @class_name, @key, :from]
            @_to_path = [:data_state, @class_name, @key, :to]
            @_revision_store_path = [:data_state, :revision, @class_name, @key]
            @_revision = revision ? revision : Redux.fetch_by_path(*@_revision_store_path)
            loaded = loaded?
            if attributes
              attributes.each { |a,v| _validate_attribute(a, v) }
              if loaded
                raw_attributes = Redux.fetch_by_path(*@_store_path)
                if `raw_attributes === null`
                  @_changed_attributes = !attributes ? {} : attributes
                elsif raw_attributes && !attributes.nil? && Hash.new(raw_attributes) != attributes
                  @_changed_attributes = attributes
                end
              else
                @_changed_attributes = attributes
              end
            else
              @_changed_attributes = {}
            end
            from = from.to_sid if from.respond_to?(:to_sid)
            if loaded && from
              @_changed_from = nil
              store_from = Redux.fetch_by_path(*@_from_path)
              @_changed_from = from unless `from == store_from`
            else
              @_changed_from = from
            end
            to = to.to_sid if to.respond_to?(:to_sid)
            if loaded && to
              @_changes_to = nil
              store_to = Redux.fetch_by_path(*@_to_path)
              @_changed_to = to unless `to == store_to`
            else
              @_changed_to = to
            end
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

          def _load_from_store!
            @_changed_attributes = {}
            @_changed_from = nil
            @_changed_to = nil
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
            sid = @_changed_from ? @_changed_from : Redux.fetch_by_path(@_from_path)
            Isomorfeus.instance_from_sid(sid)
          end

          def from=(document)
            if document.respond_to?(:to_sid)
              @_changed_from = document.to_sid
              document
            else
              @_changed_from = document
              Isomorfeus.instance_from_sid(document)
            end
          end

          def to
            sid = @_changed_to ? @_changed_to : Redux.fetch_by_path(@_to_path)
            Isomorfeus.instance_from_sid(sid)
          end

          def to=(document)
            if document.respond_to?(:to_sid)
              @_changed_to = document.to_sid
              document
            else
              @_changed_to = document
              Isomorfeus.instance_from_sid(document)
            end
          end

          def to_transport
            hash = { attributes: _get_attributes,
                     from: @_changed_from ? @_changed_from : Redux.fetch_by_path(@_from_path),
                     to: @_changed_to ? @_changed_to : Redux.fetch_by_path(@_to_path) }
            rev = revision
            hash.merge!(_revision: rev) if rev
            { @class_name => { @key => hash }}
          end
        else # RUBY_ENGINE
          unless base == LucidData::Edge::Base || base == LucidData::Link::Base
            Isomorfeus.add_valid_data_class(base)
            base.prop :pub_sub_client, default: nil
            base.prop :current_user, default: Anonymous.new
          end

          base.instance_exec do
            def load(key:, pub_sub_client: nil, current_user: nil)
              data = instance_exec(key: key, &@_load_block)
              revision = nil
              revision = data.delete(:_revision) if data.key?(:_revision)
              revision = data.delete(:revision) if !revision && data.key?(:revision)
              from = nil
              from = data.delete(:_from) if data.key?(:_from)
              from = data.delete(:from) if !from && data.key?(:from)
              to = nil
              to = data.delete(:_to) if data.key?(:_to)
              to = data.delete(:to) if !to&& data.key?(:to)
              attributes = data.delete(:attributes)
              self.new(key: key, revision: revision, from: from, to: to, attributes: attributes)
            end

            def attribute(name, options = {})
              attribute_conditions[name] = options

              define_method(name) do
                @_raw_attributes[name]
              end

              define_method("#{name}=") do |val|
                _validate_attribute(name, val)
                changed!
                @_raw_attributes[name] = val
              end
            end
          end

          def initialize(key:, revision: nil, from:, to:, attributes: nil, collection: nil)
            @key = key.to_s
            @_revision = revision
            @_changed = false
            @class_name = self.class.name
            @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
            @_collection = collection
            @_validate_attributes = self.class.attribute_conditions.any?
            attributes = {} unless attributes
            if @_validate_attributes
              attributes.each { |a,v| _validate_attribute(a, v) }
            end
            @_raw_attributes = attributes
            @_changed_from = nil
            @_changed_to = nil
            @_raw_from = if from.respond_to?(:to_sid)
                           from.to_sid
                         else
                           from[1] = from[1].to_s
                           from
                         end
            @_raw_to = if to.respond_to?(:to_sid)
                         to.to_sid
                       else
                         to[1] = to[1].to_s
                         to
                       end
          end

          def changed?
            @_changed
          end

          def changed!
            @_collection.changed! if @_collection
            @_changed = true
          end

          def collection
            @_collection
          end

          def collection=(c)
            @_collection = c
          end

          def graph
            @_collection&.graph
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
            changed!
            @_raw_attributes[name] = val
          end

          def from
            sid = @_changed_from ? @_changed_from : @_raw_from
            graph&.node_from_sid(sid)
          end

          def from_as_sid
            @_changed_from ? @_changed_from : @_raw_from
          end

          def from=(node)
            raise "A invalid 'from' was given" unless node
            old_from = from
            if node.respond_to?(:to_sid)
              node_sid = node.to_sid
            else
              node_sid = node
              node_sid[1] = node_sid[1].to_s
              node = graph.node_from_sid(node_sid)
            end
            @_changed_from = node_sid
            @_collection.update_node_to_edge_cache(self, old_from, node) if @_collection
            node
          end

          def to
            sid = @_changed_to ? @_changed_to : @_raw_to
            graph&.node_from_sid(sid)
          end

          def to_as_sid
            @_changed_to ? @_changed_to : @_raw_to
          end

          def to=(node)
            raise "A invalid 'to' was given" unless node
            old_to = to
            if node.respond_to?(:to_sid)
              node_sid = node.to_sid
            else
              node_sid = node
              node_sid[1] = node_sid[1].to_s
              node = graph.node_from_sid(node_sid)
            end
            @_changed_to = node_sid
            @_collection.update_node_to_edge_cache(self, old_to, node) if @_collection
            node
          end

          def other(node)
            other_from = from
            other_to = to
            return other_to if other_from == node
            other_from if other_to == node
          end

          def to_transport
            attributes = {}
            self.class.attribute_conditions.each do |attr, options|
              if !options[:server_only] && @_raw_attributes.key?(attr)
                attributes[attr.to_s] = @_raw_attributes[attr]
              end
            end
            hash = { "attributes" => attributes,
                     "from" => @_changed_from ? @_changed_from : @_raw_from,
                     "to" => @_changed_to ? @_changed_to : @_raw_to }
            hash.merge!("_revision" => revision ) if revision
            { @class_name => { @key => hash }}
          end
        end # RUBY_ENGINE
      end
    end
  end
end
