module LucidData
  module Graph
    module Mixin
      def self.included(base)
        base.include(Enumerable)
        base.extend(LucidPropDeclaration::Mixin)
        base.extend(Isomorfeus::Data::GenericClassApi)
        base.include(Isomorfeus::Data::GenericInstanceApi)
        base.include(LucidData::Graph::Finders)

        base.instance_exec do
          def attribute_conditions
            @attribute_conditions ||= {}
          end

          def valid_attribute?(attr_name, attr_value)
            Isomorfeus::Props::Validator.new(self.name, attr_name, attr_value, attribute_conditions[attr_name]).validate!
          rescue
            false
          end

          def edge_collections
            @edge_collections ||= {}
          end

          def node_collections
            @node_collections ||= {}
          end
        end

        def _validate_attribute(attr_name, attr_val)
          raise "No such attribute declared: '#{attr_name}'!" unless self.class.attribute_conditions.key?(attr_name)
          Isomorfeus::Props::Validator.new(@class_name, attr_name, attr_val, self.class.attribute_conditions[attr_name]).validate!
        end

        def to_transport
          { @class_name => { @key => { attributes: _get_attributes, edge_collection: edge_collection.to_sid, node_collection: node_collection.to_sid }}}
        end

        def included_items_to_transport
          hash = edge_collection.to_transport
          hash.merge!(node_collection.to_transport)
          hash.merge!(edge_collection.included_items_to_transport)
          hash.merge!(node_collection.included_items_to_transport)
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

            def nodes(access_name, collection_class = nil)
              node_collections[access_name] = collection_class

              define_method(access_name) do

              end

              define_method("#{access_name}=") do |collection|

              end

              if collection_class
                singular_access_name = access_name.to_s.singularize
                define_singleton_method("valid_#{singular_access_name}?") do |node|
                  collection_class.valid_node?(node)
                end
              end
            end
            alias documents nodes
            alias vertices nodes
            alias vertexes nodes

            def edges(access_name, collection_class = nil)
              edge_collections[access_name] = collection_class

              define_method(access_name) do

              end

              define_method("#{access_name}=") do |collection|

              end

              if collection_class
                singular_access_name = access_name.to_s.singularize
                define_singleton_method("valid_#{singular_access_name}?") do |edge|
                  collection_class.valid_edge?(edge)
                end
              end
            end
            alias links edges
          end

          def initialize(key:, revision: nil, attributes: nil, edges: nil, nodes: nil, documents: nil)
            @key = key.to_s
            @class_name = self.class.name
            @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
            @_store_path = [:data_state, @class_name, @key, :attributes]
            @_edge_collection_path = [:data_state, @class_name, @key, :edge_collection]
            @_node_collection_path = [:data_state, @class_name, @key, :node_collection]
            @_revision_store_path = [:data_state, @class_name, @key, :revision]
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
            nodes = nodes || documents
            edge_collection = edge_collection.to_sid if edge_collection.respond_to?(:to_sid)
            if loaded && edge_collection
              @_edge_collection_sid = edge_collection ? edge_collection : Redux.fetch_by_path(*@_edge_collection_path)
            else
              @_edge_collection_sid = edge_collection
            end
            node_collection = document_collection || node_collection
            node_collection = node_collection.to_sid if node_collection.respond_to?(:to_sid)
            if loaded && node_collection
              @_node_collection_sid = node_collection ? node_collection : Redux.fetch_by_path(*@_node_collection_path)
            else
              @_node_collection_sid = node_collection
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
            @_edge_collection_sid = nil
            @_node_collection_sid = nil
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
            sid = node_collection_sid
            return Isomorfeus.instance_from_sid(sid) if sid
            []
          end
          alias document_collection node_collection
          alias nodes node_collection
          alias documents node_collection

          def node_collection_sid
            @_node_collection_sid ||= Redux.fetch_by_path(*@_node_collection_path)
          end
          alias document_collection_sid node_collection_sid

          def edge_collection
            sid = edge_collection_sid
            return Isomorfeus.instance_from_sid(sid) if sid
            []
          end
          alias edges edge_collection

          def edge_collection_sid
            @_edge_collection_sid ||= Redux.fetch_by_path(*@_edge_collection_path)
          end
        else # RUBY_ENGINE
          unless base == LucidData::Graph::Base
            Isomorfeus.add_valid_data_class(base)
            base.prop :pub_sub_client, default: nil
            base.prop :current_user, default: Anonymous.new
          end

          base.instance_exec do
            def load(key:, pub_sub_client: nil, current_user: nil)
              data = instance_exec(key: key, &@_load_block)

              STDERR.puts "data: #{data}"
              revision = nil
              revision = data.delete(:_revision) if data.key?(:_revision)
              revision = data.delete(:revision) if !revision && data.key?(:revision)
              nodes = data.delete(:nodes)
              edges = data.delete(:edges)
              attributes = data.delete(:attributes)
              self.new(key: key, revision: revision, edges: edges, nodes: nodes, attributes: attributes)
            end

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


            def nodes(access_name, collection_class = nil)
              node_collections[access_name] = collection_class

              define_method(access_name) do
                @_node_collections[access_name]
              end

              define_method("#{access_name}=") do |collection|
                @_changed_true
                @_node_collections[access_name] = collection
                @_node_collections[access_name].graph = self
                @_node_collections[access_name]
              end

              if collection_class
                singular_access_name = access_name.to_s.singularize
                define_singleton_method("valid_#{singular_access_name}?") do |node|
                  collection_class.valid_node?(node)
                end
              end
            end
            alias documents nodes
            alias vertices nodes
            alias vertexes nodes

            def edges(access_name, collection_class = nil)
              edge_collections[access_name] = collection_class

              define_method(access_name) do
                @_edge_collections[access_name]
              end

              define_method("#{access_name}=") do |collection|
                @_changed = true
                @_edge_collections[access_name] = collection
                @_edge_collections[access_name].graph = self
                @_edge_collections[access_name]
              end

              if collection_class
                singular_access_name = access_name.to_s.singularize
                define_singleton_method("valid_#{singular_access_name}?") do |edge|
                  collection_class.valid_edge?(edge)
                end
              end
            end
            alias links edges
          end

          def initialize(key:, revision: nil, attributes: nil, edges: nil, nodes: nil)
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
            @_node_collections = {}
            if nodes.class == Hash
              self.class.node_collections.each_key do |access_name|
                if nodes.key?(access_name)
                  @_node_collections[access_name] = nodes[access_name]
                  @_node_collections[access_name].graph = self
                end
              end
            else
              @_node_collections[:nodes] = nodes
              @_node_collections[:nodes].graph = self
            end
            @_edge_collections = {}
            if edges.class == Hash
              self.class.edge_collections.each_key do |access_name|
                if edges.key?(access_name)
                  @_edge_collections[access_name] = edges[access_name]
                  @_edge_collections[access_name].graph = self
                end
              end
            else
              @_edge_collections[:edges] = edges
              @_edge_collections[:edges].graph = self
            end
          end

          def _get_attributes
            @_raw_attributes
          end

          def changed?
            @_changed
          end

          def changed!
            @_changed = true
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

          def edges_for_node(node)
            node_edges = []
            @_edge_collections.each_value do |collection|
              node_edges.push(collection.edges_for_node(node))
            end
            node_edges
          end

          def linked_nodes_for_node(node)
            node_edges = edges_for_node(node)
            nodes = []
            node_sid = node.to_sid
            node_edges.each do |edge|
              from_sid = edge.from.to_sid
              to_sid = edge.to.to_sid
              if to_sid == node_sid
                nodes << edge.from
              elsif from_sid == node_sid
                nodes << edge.to
              end
            end
            nodes
          end

          def node_from_sid(sid)
            node = nil
            @_node_collections.each_value do |collection|
              node = collection.node_from_sid(sid)
              break if node
            end
            node
          end

          def nodes
            all_nodes = []
            @_node_collections.each_value do |collection|
              all_nodes.push(*collection.nodes)
            end
            all_nodes
          end

          def edges
            all_edges = []
            @_edge_collections.each_value do |collection|
              all_edges.push(*collection.edges)
            end
            all_edges
          end
        end  # RUBY_ENGINE
      end
    end
  end
end
