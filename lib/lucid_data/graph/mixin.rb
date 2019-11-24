module LucidData
  module Graph
    module Mixin
      # TODO nodes -> documents
      # TODO inline store path
      def self.included(base)
        base.include(Enumerable)
        base.extend(LucidPropDeclaration::Mixin)
        base.extend(Isomorfeus::Data::GenericClassApi)
        base.include(Isomorfeus::Data::GenericInstanceApi)
        base.include(LucidData::Graph::Finders)

        base.instance_exec do
          def _handler_type
            'graph'
          end

          def nodes(node_class = nil, &block)
            @node_class = node_class
            @edge_block = block
          end
          alias documents nodes

          def edges(edge_class, &block)
            @edge_class = edge_class
            @edge_block = block
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

        def to_transport
          { @class_name => { @key => { edge_collection: edge_collection.to_transport, node_collection: node_collection.to_transport }}}
        end

        def included_items_to_transport
          edge_collection.included_items_to_transport + node_collection.included_items_to_transport
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

          def initialize(key:, revision: nil, node_collection: nil, edge_collection: nil, attributes: nil)
            @key = key.to_s
            @class_name = self.class.name
            @_store_path = [:data_state, @class_name, @key, :attributes]
            @_edge_collection_path = [:data_state, @class_name, @key, :edge_collection]
            @_node_collection_path = [:data_state, @class_name, @key, :node_collection]
            edge_collection = edge_collection.to_sid if edge_collection.respond_to?(:to_sid)
            node_collection = node_collection.to_sid if node_collection.respond_to?(:to_sid)
            @_edge_collection_sid = edge_collection ? edge_collection : Redux.fetch_by_path(*@_edge_collection_path)
            @_node_collection_sid = node_collection ? node_collection : Redux.fetch_by_path(*@_node_collection_path)
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
            edge_collection.changed? || node_collection.changed? || @_changed_attributes.any?
          end

          def revision
            @_revision
          end

          def [](name)
            _get_attribute(name)
          end

          def []=(name, val)
            _validate_attribute(name, val)
            @_changed_attributes[name] = val
          end

          def node_collection
            Isomorfeus.instance_from_sid(@_node_collection_sid)
          end

          def nodes
            nodes_collection.map
          end

          def edge_collection
            Isomorfeus.instance_from_sid(@_edge_collection_sid)
          end

          def edges
            edge_collection.map
          end
        else # RUBY_ENGINE
          unless base == LucidData::Graph::Base
            Isomorfeus.add_valid_generic_collection_class(base)
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

          def initialize(key:, revision: nil, node_collection: nil, edge_collection: nil)
            @key = key.to_s
            @_revision = revision
            @_changed = false
            @class_name = self.class.name
            @_edge_collection = edge_collection
            @_node_collection = node_collection
          end

          def changed?
            edge_collection.changed? || nodes_collection.changed? || @_changed_attributes.any?
          end

          def revision
            @_revision
          end

          def [](name)
            @_raw_attributes[name]
          end

          def []=(name, val)
            _validate_attribute(name, val)
            @_changed = true
            @_raw_attributes[name] = val
          end

          def node_collection
            @_node_collection
          end

          def nodes
            node_collection.map
          end

          def edge_collection
            @_edge_collection
          end

          def edges
            edge_collection.map
          end
        end  # RUBY_ENGINE
      end
    end
  end
end
