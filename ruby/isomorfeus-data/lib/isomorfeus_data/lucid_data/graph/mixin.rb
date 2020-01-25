module LucidData
  module Graph
    module Mixin
      def self.included(base)
        base.include(Enumerable)
        base.extend(LucidPropDeclaration::Mixin)
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
          alias vertices nodes
          alias vertexes nodes

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
          alias links edges

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
          if method_name_s.start_with?('find_edge_by_') || method_name_s.start_with?('find_link_by_')
            attribute = method_name_s[13..-1] # remove 'find_by_'
            value = args[0]
            attribute_hash = { attribute => value }
            attribute_hash.merge!(args[1]) if args[1]
            find_edge(attribute_hash)
          elsif method_name_s.start_with?('find_node_by_') || method_name_s.start_with?('find_document_by_') || method_name_s.start_with?('find_vertex_by_')
            attribute = if method_name_s.start_with?('find_node_by_')
                          method_name_s[13..-1]
                        elsif method_name_s.start_with?('find_document_by_')
                          method_name_s[17..-1]
                        elsif method_name_s.start_with?('find_vertex_by_')
                          method_name_s[15..-1]
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
        alias vertex_from_sid node_from_sid

        def nodes
          all_nodes = []
          node_collections.each_value do |collection|
            all_nodes.push(*collection.nodes)
          end
          all_nodes
        end
        alias documents nodes
        alias vertices nodes
        alias vertexes nodes

        def edges
          all_edges = []
          edge_collections.each_value do |collection|
            all_edges.push(*collection.edges)
          end
          all_edges
        end
        alias links edges

        def changed?
          @_changed
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
          hash.merge!('revision' => revision) if revision
          { @class_name => { @key => hash }}
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
          def initialize(key:, revision: nil, attributes: nil, edges: nil, links: nil, nodes: nil, documents: nil, vertices: nil, vertexes: nil, composition: nil)
            @key = key.to_s
            @class_name = self.class.name
            @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
            @_store_path = [:data_state, @class_name, @key, :attributes]
            @_edges_path = [:data_state, @class_name, @key, :edges]
            @_nodes_path = [:data_state, @class_name, @key, :nodes]
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
            nodes = nodes || documents || vertices || vertexes
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
            edges = edges || links
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

          def edge_collections
            _init_edge_collections if @_edge_collections.empty?
            @_edge_collections
          end
          alias link_collections edge_collections

          def node_collections
            _init_node_collections if @_node_collections.empty?
            @_node_collections
          end
          alias document_collections node_collections
          alias vertex_collections node_collections
        else # RUBY_ENGINE
          unless base == LucidData::Graph::Base
            Isomorfeus.add_valid_data_class(base)
            base.prop :pub_sub_client, default: nil
            base.prop :current_user, default: Anonymous.new
          end

          base.instance_exec do
            def load(key:, pub_sub_client: nil, current_user: nil)
              data = instance_exec(key: key, pub_sub_client: pub_sub_client, current_user: current_user, &@_load_block)
              return nil unless data
              return data if data.class == self
              Isomorfeus.raise_error "#{self.to_s}: execute_load must return either a Hash or a instance of #{self.to_s}. Returned was: #{data.class}." if data.class != ::Hash
              revision = data.delete(:revision)
              nodes = data.delete(:nodes)
              edges = data.delete(:edges)
              attributes = data.delete(:attributes)
              self.new(key: key, revision: revision, edges: edges, nodes: nodes, attributes: attributes)
            end

            def save(key:, revision: nil, attributes: nil, edges: nil, links: nil, nodes: nil, documents: nil, vertices: nil, vertexes: nil,
                     pub_sub_client: nil, current_user: nil)
              attributes = {} unless attributes
              val_edges = edges || links
              val_nodes = documents || nodes || vertexes || vertices
              _validate_attributes(attributes) if attributes.any?
              _validate_edges(val_edges)
              _validate_nodes(val_nodes)
              data = instance_exec(key: key, revision: revision, parts: parts, attributes: attributes,
                                   pub_sub_client: pub_sub_client, current_user: current_user, &@_save_block)
              return nil unless data
              return data if data.class == self
              Isomorfeus.raise_error "#{self.to_s}: execute_save must return either a Hash or a instance of #{self.to_s}. Returned was: #{data.class}." if data.class != ::Hash
              revision = data.delete(:revision)
              attributes = data.delete(:attributes)
              documents = data.delete(:documents)
              vertexes = data.delete(:vertexes)
              vertices = data.delete(:vertices)
              nodes = data.delete(:nodes)
              edges = data.delete(:edges)
              links = data.delete(:links)
              self.new(key: key, revision: revision, attributes: attributes, edges: edges, links: links, nodes: nodes, documents: documents,
                       vertices: vertices, vertexes: vertexes, pub_sub_client: nil, current_user: nil)
            end
          end

          def initialize(key:, revision: nil, attributes: nil, edges: nil, links: nil, nodes: nil, documents: nil, vertices: nil, vertexes: nil,
                         composition: nil)
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
            nodes = nodes || documents || vertices || vertexes
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
            edges = edges || links
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

          def edge_collections
            @_edge_collections
          end
          alias link_collections edge_collections

          def node_collections
            @_node_collections
          end
          alias document_collections node_collections
          alias vertex_collections node_collections
        end  # RUBY_ENGINE
      end
    end
  end
end
