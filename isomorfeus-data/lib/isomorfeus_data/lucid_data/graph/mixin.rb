module LucidData
  module Graph
    module Mixin
      def self.included(base)
        base.include(Enumerable)
        base.include(Isomorfeus::Data::AttributeSupport)
        base.extend(Isomorfeus::Data::GenericClassApi)
        base.include(Isomorfeus::Data::GenericInstanceApi)
        base.include(LucidData::Graph::Finders)

        base.instance_exec do
          def edge_collections
            @edge_collections ||= {}
          end

          def node_collections
            @node_collections ||= {}
          end

          def nodes(access_name, validate_hash = {})
            node_collections[access_name] = validate_hash

            define_method(access_name) do
              node_collections[access_name]
            end

            define_method("#{access_name}=") do |collection|
              _validate_node_collection(access_name, collection)
              @_changed = true
              node_collections[access_name] = collection
              node_collections[access_name].graph = self
              node_collections[access_name]
            end

            define_singleton_method("valid_#{access_name}?") do |collection|
              _validate_node_collection(access_name, collection)
            rescue
              false
            end
          end
          alias documents nodes

          def _validate_nodes(nodes_hash_or_array)
            if nodes_hash_or_array.class == ::Hash
              nodes_hash_or_array.each do |access_name, collection|
                _validate_node_collection(access_name, collection)
              end
            else
              _validate_node_collection(:nodes, nodes_hash_or_array)
            end
          end

          def _validate_node_collection(access_name, collection)
            unless node_collections.key?(access_name) || access_name == :nodes
              Isomorfeus.raise_error(message: "#{self.name}: No such node collection declared: '#{access_name}'!")
            end
            Isomorfeus::Data::ElementValidator.new(self.name, collection, node_collections[access_name]).validate! if node_collections[access_name]
          end

          def edges(access_name, validate_hash = {})
            edge_collections[access_name] = validate_hash

            define_method(access_name) do
              edge_collections[access_name]
            end

            define_method("#{access_name}=") do |collection|
              _validate_edge_collection(access_name, collection)
              @_changed = true
              edge_collections[access_name] = collection
              edge_collections[access_name].graph = self
              edge_collections[access_name]
            end

            define_singleton_method("valid_#{access_name}?") do |collection|
              _validate_edge_collection(access_name, collection)
            rescue
              false
            end
          end

          def _validate_edges(edges_hash_or_array)
            if edges_hash_or_array.class == ::Hash
              edges_hash_or_array.each do |access_name, collection|
                _validate_edge_collection(access_name, collection)
              end
            else
              _validate_edge_collection(:edges, edges_hash_or_array)
            end
          end

          def _validate_edge_collection(access_name, collection)
            unless edge_collections.key?(access_name) || access_name == :edges
              Isomorfeus.raise_error(message: "#{self.name}: No such edge collection declared: '#{access_name}'!")
            end
            Isomorfeus::Data::ElementValidator.new(self.name, collection, edge_collections[access_name]).validate! if edge_collections[access_name]
          end
        end

        def _validate_edges(edges_hash_or_array)
          self.class._validate_edges(edges_hash_or_array)
        end

        def _validate_edge_collection(access_name, collection)
          self.class._validate_edge_collection(access_name, collection)
        end

        def _validate_nodes(nodes_hash_or_array)
          self.class._validate_nodes(nodes_hash_or_array)
        end

        def _validate_node_collection(access_name, collection)
          self.class._validate_node_collection(access_name, collection)
        end

        def method_missing(method_name, *args, &block)
          method_name_s = method_name.to_s
          if method_name_s.start_with?('find_edge_by_')
            attribute = method_name_s[13..-1] # remove 'find_by_'
            value = args[0]
            attribute_hash = { attribute => value }
            attribute_hash.merge!(args[1]) if args[1]
            find_edge(attribute_hash)
          elsif method_name_s.start_with?('find_node_by_') || method_name_s.start_with?('find_document_by_')
            attribute = if method_name_s.start_with?('find_node_by_')
                          method_name_s[13..-1]
                        elsif method_name_s.start_with?('find_document_by_')
                          method_name_s[17..-1]
                        end
            value = args[0]
            attribute_hash = { attribute => value }
            attribute_hash.merge!(args[1]) if args[1]
            find_node(attribute_hash)
          else
            super(method_name, *args, &block)
          end
        end

        def edges_for_node(node)
          node_edges = []
          edge_collections.each_value do |collection|
            node_edges.push(*collection.edges_for_node(node))
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
          node_collections.each_value do |collection|
            node = collection.node_from_sid(sid)
            break if node
          end
          node
        end
        alias document_from_sid node_from_sid

        def nodes
          all_nodes = []
          node_collections.each_value do |collection|
            all_nodes.push(*collection.nodes)
          end
          all_nodes
        end
        alias documents nodes

        def edges
          all_edges = []
          edge_collections.each_value do |collection|
            all_edges.push(*collection.edges)
          end
          all_edges
        end

        def changed!
          @_composition.changed! if @_composition
          @_changed = true
        end

        def composition
          @_composition
        end

        def composition=(c)
          @_composition = c
        end

        def to_transport
          hash = { 'attributes' => _get_selected_attributes, 'nodes' => {}, 'edges' => {} }
          node_collections.each do |name, collection|
            hash['nodes'][name.to_s] = collection.to_sid if collection
          end
          edge_collections.each do |name, collection|
            hash['edges'][name.to_s] = collection.to_sid if collection
          end
          hash['revision'] = revision if revision
          result = { @class_name => { @key => hash }}
          result.deep_merge!(@class_name => { @previous_key => { new_key: @key}}) if @previous_key
          result
        end

        def included_items_to_transport
          hash = {}
          node_collections.each_value do |collection|
            if collection
              hash.deep_merge!(collection.to_transport)
              hash.deep_merge!(collection.included_items_to_transport)
            end
          end
          edge_collections.each_value do |collection|
            if collection
              hash.deep_merge!(collection.to_transport)
              hash.deep_merge!(collection.included_items_to_transport)
            end
          end
          hash
        end

        if RUBY_ENGINE == 'opal'
          def initialize(key:, revision: nil, attributes: nil, edges: nil, nodes: nil, documents: nil, composition: nil)
            @key = key.to_s
            @class_name = self.class.name
            @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
            _update_paths
            @_revision = revision ? revision : Redux.fetch_by_path(:data_state, @class_name, @key, :revision)
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

            # nodes
            @_node_collections = {}
            nodes = nodes || documents
            if nodes && loaded
              _validate_nodes(nodes)
              if nodes.class == ::Hash
                self.class.node_collections.each_key do |access_name|
                  if nodes.key?(access_name)
                    collection = nodes[access_name]
                    @_node_collections[access_name] = if collection.respond_to?(:to_sid)
                                                        collection
                                                      else
                                                        Isomorfeus.instance_from_sid(collection)
                                                      end
                  end
                end
              else
                @_node_collections[:nodes] = if nodes.respond_to?(:to_sid)
                                               nodes
                                             else
                                               Isomorfeus.instance_from_sid(nodes)
                                             end
              end
            elsif loaded
              self.class.node_collections.each_key do |access_name|
                sid = Redux.fetch_by_path(*(@_nodes_path + [access_name]))
                @_node_collections[access_name] = Isomorfeus.instance_from_sid(sid) if sid
              end
            end
            @_node_collections.each_value { |collection| collection.graph = self }

            # edges
            @_edge_collections = {}
            edges = edges
            if edges && loaded
              _validate_edges(edges)
              if edges.class == ::Hash
                self.class.edge_collections.each_key do |access_name|
                  if edges.key?(access_name)
                    collection = edges[access_name]
                    @_edge_collections[access_name] = if collection.respond_to?(:to_sid)
                                                        collection
                                                      else
                                                        Isomorfeus.instance_from_sid(collection)
                                                      end
                  end
                end
              else
                @_edge_collections[:edges] = if edges.respond_to?(:to_sid)
                                               edges
                                             else
                                               Isomorfeus.instance_from_sid(edges)
                                             end
              end
            elsif loaded
              self.class.edge_collections.each_key do |access_name|
                sid = Redux.fetch_by_path(*(@_edges_path + [access_name]))
                @_edge_collections[access_name] = Isomorfeus.instance_from_sid(sid) if sid
              end
            end
            @_edge_collections.each_value { |collection| collection.graph = self }
          end

          def _init_node_collections
            keys = self.class.node_collections.keys
            keys << :nodes if keys.empty?
            keys.each do |access_name|
              sid = Redux.fetch_by_path(*(@_nodes_path + [access_name]))
              if sid
                @_node_collections[access_name] = Isomorfeus.instance_from_sid(sid)
                @_node_collections[access_name].graph = self
              end
            end
          end

          def _init_edge_collections
            keys = self.class.edge_collections.keys
            keys << :edges if keys.empty?
            keys.each do |access_name|
              sid = Redux.fetch_by_path(*(@_edges_path + [access_name]))
              if sid
                @_edge_collections[access_name] = Isomorfeus.instance_from_sid(sid)
                @_edge_collections[access_name].graph = self
              end
            end
          end

          def _load_from_store!
            @_changed = false
            @_changed_attributes = {}
            @_node_collections = {}
            @_edge_collections = {}
            nil
          end

          def _update_paths
            @_store_path = [:data_state, @class_name, @key, :attributes]
            @_edges_path = [:data_state, @class_name, @key, :edges]
            @_nodes_path = [:data_state, @class_name, @key, :nodes]
          end

          def edge_collections
            _init_edge_collections if @_edge_collections.empty?
            @_edge_collections
          end

          def node_collections
            _init_node_collections if @_node_collections.empty?
            @_node_collections
          end
          alias document_collections node_collections
        else # RUBY_ENGINE
          Isomorfeus.add_valid_data_class(base) unless base == LucidData::Graph::Base

          base.instance_exec do
            def instance_from_transport(instance_data, included_items_data)
              key = instance_data[self.name].keys.first
              revision = instance_data[self.name][key].key?('revision') ? instance_data[self.name][key]['revision'] : nil
              attributes = instance_data[self.name][key].key?('attributes') ? instance_data[self.name][key]['attributes'].transform_keys!(&:to_sym) : nil

              nodes_hash = instance_data[self.name][key].key?('nodes') ? instance_data[self.name][key]['nodes'] : {}
              edges_hash = instance_data[self.name][key].key?('edges') ? instance_data[self.name][key]['edges'] : {}

              nodes_edges = [{},{}]
              [nodes_hash, edges_hash].each_with_index do |hash, hash_index|
                hash.each do |name, value|
                  namsy = name.to_sym
                  nodes_edges[namsy] = []
                  value.each do |sid|
                    node_class_name = sid[0]
                    node_key = sid[1]
                    Isomorfeus.raise_error(message: "#{self.name}: #{node_class_name}: Not a valid LucidData class!") unless Isomorfeus.valid_data_class_name?(node_class_name)
                    if included_items_data.key?(node_class_name) && included_items_data[node_class_name].key?(node_key)
                      node_class = Isomorfeus.cached_data_class(node_class_name)
                      Isomorfeus.raise_error(message: "#{self.name}: #{node_class_name}: Cannot get class!") unless node_class
                      node = node_class.instance_from_transport({ node_class_name => { node_key => included_items_data[node_class_name][node_key] }}, included_items_data)
                      Isomorfeus.raise_error(message: "#{self.name}: #{node_class_name} with key #{node_key} could not be extracted from transport data!") unless node
                      nodes_edges[hash_index][namsy] << node
                    end
                  end
                end
              end

              new(key: key, revision: revision, attributes: attributes, nodes: nodes_edges[0], edges: nodes_edges[1])
            end
          end

          def initialize(key:, revision: nil, attributes: nil, edges: nil, nodes: nil, documents: nil, composition: nil)
            @key = key.to_s
            @class_name = self.class.name
            @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
            @_revision = revision
            @_changed = false
            @_composition = composition
            attributes = {} unless attributes
            _validate_attributes(attributes) if attributes.any?
            @_raw_attributes = attributes

            # nodes
            @_node_collections = {}
            nodes = nodes || documents
            if nodes.class == ::Hash
              _validate_nodes(nodes)
              self.class.node_collections.each_key do |access_name|
                if nodes.key?(access_name)
                  @_node_collections[access_name] = nodes[access_name]
                  @_node_collections[access_name].graph = self
                end
              end
            else
              _validate_nodes(nodes) if nodes
              @_node_collections[:nodes] = nodes
              @_node_collections[:nodes].graph = self if @_node_collections[:nodes].respond_to?(:graph=)
            end

            # edges
            @_edge_collections = {}
            edges = edges
            if edges.class == ::Hash
              _validate_edges(edges)
              self.class.edge_collections.each_key do |access_name|
                if edges.key?(access_name)
                  @_edge_collections[access_name] = edges[access_name]
                  @_edge_collections[access_name].graph = self
                end
              end
            else
              _validate_edges(edges) if edges
              @_edge_collections[:edges] = edges
              @_edge_collections[:edges].graph = self if @_edge_collections[:edges].respond_to?(:graph=)
            end
          end

          def _unchange!
            @_changed = false
          end

          def edge_collections
            @_edge_collections
          end

          def node_collections
            @_node_collections
          end
          alias document_collections node_collections
        end  # RUBY_ENGINE
      end
    end
  end
end
