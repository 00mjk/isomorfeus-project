module LucidData
  module Node
    module Mixin
      def self.included(base)
        base.include(Isomorfeus::Data::AttributeSupport)
        base.extend(Isomorfeus::Data::GenericClassApi)
        base.include(Isomorfeus::Data::GenericInstanceApi)

        def changed?
          @_changed
        end

        def changed!
          @_collection.changed! if @_collection
          @_composition.changed! if @_composition
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

        def composition
          @_composition
        end

        def composition=(c)
          @_composition = c
        end

        def edges
          graph&.edges_for_node(self)
        end

        def linked_nodes
          graph&.linked_nodes_for_node(self)
        end

        def to_transport
          hash = { 'attributes' => _get_selected_attributes }
          hash.merge!('revision' => revision) if revision
          result = { @class_name => { @key => hash }}
          result.deep_merge!(@class_name => { @previous_key => { new_key: @key}}) if @previous_key
          result
        end

        if RUBY_ENGINE == 'opal'
          def initialize(key:, revision: nil, attributes: nil, collection: nil, composition: nil)
            @key = key.to_s
            @class_name = self.class.name
            @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
            _update_paths
            @_revision = revision ? revision : Redux.fetch_by_path(:data_state, :revision, @class_name, @key)
            @_collection = collection
            @_composition = composition
            @_changed = false
            loaded = loaded?
            if attributes
              _validate_attributes(attributes)
              if loaded
                raw_attributes = Redux.fetch_by_path(*@_store_path)
                if `raw_attributes === null`
                  @_changed_attributes = !attributes ? {} : attributes
                elsif raw_attributes && !attributes.nil? && ::Hash.new(raw_attributes) != attributes
                  @_changed_attributes = attributes
                end
              else
                @_changed_attributes = attributes
              end
            else
              @_changed_attributes = {}
            end
          end

          def _load_from_store!
            @_changed_attributes = {}
            @_changed = false
          end

          def _update_paths
            @_store_path = [:data_state, @class_name, @key, :attributes]
          end

          def each(&block)
            attributes.each(&block)
          end

          def [](name)
            _get_attribute(name)
          end

          def []=(name, val)
            _validate_attribute(name, val)
            changed!
            @_changed_attributes[name] = val
          end

          def method_missing(method_name, *args, &block)
            if graph
              singular_name = `method_name.endsWith('s')` ? method_name.singularize : method_name
              node_edges = edges
              sid = to_sid
              camelized_singular = singular_name.camelize

              if method_name == singular_name
                # return one node
                node_edges.each do |edge|
                  from_sid = edge.from_as_sid
                  to_sid = edge.to_as_sid
                  node = if from_sid[0] == camelized_singular && to_sid == sid
                           edge.from
                         elsif to_sid[0] == camelized_singular && from_sid == sid
                           edge.to
                         end
                  return node if node
                end
                nil
              elsif method_name == method_name.pluralize
                # return all nodes
                nodes = []
                node_edges.each do |edge|
                  from_sid = edge.from_as_sid
                  to_sid = edge.to_as_sid
                  node = if from_sid[0] == camelized_singular && to_sid == sid
                           edge.from
                         elsif to_sid[0] == camelized_singular && from_sid == sid
                           edge.to
                         end
                  nodes << node if node
                end
                return nodes
              end
            else
              super(method_name, *args, &block)
            end
          end
        else # RUBY_ENGINE
          Isomorfeus.add_valid_data_class(base) unless base == LucidData::Node::Base || base == LucidData::Document::Base || base == LucidData::Vertex::Base

          base.instance_exec do
            def instance_from_transport(instance_data, _included_items_data)
              key = instance_data[self.name].keys.first
              revision = instance_data[self.name][key].key?('revision') ? instance_data[self.name][key]['revision'] : nil
              attributes = instance_data[self.name][key].key?('attributes') ? instance_data[self.name][key]['attributes'].transform_keys!(&:to_sym) : nil
              new(key: key, revision: revision, attributes: attributes)
            end
          end

          def initialize(key:, revision: nil, attributes: nil, collection: nil, composition: nil)
            @key = key.to_s
            @class_name = self.class.name
            @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
            @_revision = revision
            @_collection = collection
            @_composition = composition
            @_changed = false
            attributes = {} unless attributes
            _validate_attributes(attributes) if attributes
            @_raw_attributes = attributes
          end

          def _unchange!
            @_changed = false
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

          def method_missing(method_name, *args, &block)
            if graph
              method_name_s = method_name.to_s
              singular_name = method_name_s.singularize
              node_edges = edges
              sid = to_sid
              camelized_singular = singular_name.camelize

              if method_name_s == singular_name
                # return one node
                node_edges.each do |edge|
                  from_sid = edge.from_as_sid
                  to_sid = edge.to_as_sid
                  node = if from_sid[0] == camelized_singular && to_sid == sid
                           edge.from
                         elsif to_sid[0] == camelized_singular && from_sid == sid
                           edge.to
                         end
                  return node if node
                end
                nil
              elsif method_name_s == method_name_s.pluralize
                # return all nodes
                nodes = []
                node_edges.each do |edge|
                  from_sid = edge.from_as_sid
                  to_sid = edge.to_as_sid
                  node = if from_sid[0] == camelized_singular && to_sid == sid
                           edge.from
                         elsif to_sid[0] == camelized_singular && from_sid == sid
                           edge.to
                         end
                  nodes << node if node
                end
                return nodes
              end
            else
              super(method_name, *args, &block)
            end
          end
        end # RUBY_ENGINE
      end
    end
  end
end
