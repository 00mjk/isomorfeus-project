module LucidComposableGraph
  module Mixin
    # TODO nodes -> documents
    # TODO include -> compose dsl
    # TODO inline store path
    def self.included(base)
      base.extend(LucidPropDeclaration::Mixin)
      base.extend(Isomorfeus::Data::GenericClassApi)
      base.include(Isomorfeus::Data::GenericInstanceApi)
      base.include(LucidComposableGraph::Finders)

      base.instance_exec do
        def _handler_type
          'graph'
        end
      end

      def to_transport(inline: false)
        items_hash = {}
        own_edge_sids = own_edges_as_sids
        own_node_sids = own_nodes_as_sids
        items_hash['generic_edges'] = own_edge_sids.to_a if own_edge_sids.size > 0
        items_hash['generic_nodes'] = own_node_sids.to_a if own_node_sids.size > 0

        if @included_arrays.size > 0
          items_hash['included_arrays'] = {}
          @included_arrays.each do |name, instance|
            items_hash['included_arrays'][name.to_s] = if self.class.included_arrays[name].key?(:anonymous)
                                                         instance.to_transport(inline: true)
                                                       else
                                                         instance.to_sid
                                                       end
          end
        end

        if @included_collections.size > 0
          items_hash['included_collections'] = {}
          @included_collections.each do |name, instance|
            items_hash['included_collections'][name.to_s] = if self.class.included_collections[name].key?(:anonymous)
                                                              instance.to_transport(inline: true)
                                                            else
                                                              instance.to_sid
                                                            end
          end
        end

        if @included_graphs.size > 0
          items_hash['included_graphs'] = {}
          @included_graphs.each do |name, instance|
            items_hash['included_graphs'][name.to_s] = if self.class.included_graphs[name].key?(:anonymous)
                                                         instance.to_transport(inline: true)
                                                       else
                                                         instance.to_sid
                                                       end
          end
        end

        if @included_hashes.size > 0
          items_hash['included_hashes'] = {}
          @included_hashes.each do |name, instance|
            items_hash['included_hashes'][name.to_s] = if self.class.included_hashes[name].key?(:anonymous)
                                                         instance.to_transport(inline: true)
                                                       else
                                                         instance.to_sid
                                                       end
          end
        end

        incl_nodes = included_nodes
        if incl_nodes.size > 0
          items_hash['included_nodes'] = {}
          incl_nodes.each do |name, instance|
            items_hash['included_nodes'][name.to_s] = instance.to_sid
          end
        end

        first_key = inline ? '_inline' : 'composable_graphs'
        { first_key => { @class_name => { @key => items_hash }}}
      end

      def included_items_to_transport
        result_hash = {}

        self.class.included_arrays.each do |name, options|
          unless options.key?(:anonymous)
            result_hash.deep_merge!(@included_arrays[name].to_transport)
          end
        end

        self.class.included_collections.each do |name, options|
          unless options.key?(:anonymous)
            result_hash.deep_merge!(@included_collections[name].to_transport)
          end
          result_hash.deep_merge!(@included_collections[name].included_items_to_transport)
        end

        self.class.included_graphs.each do |name, options|
          unless options.key?(:anonymous)
            result_hash.deep_merge!(@included_graphs[name].to_transport)
          end
          result_hash.deep_merge!(@included_graphs[name].included_items_to_transport)
        end

        self.class.included_hashes.each do |name, options|
          unless options.key?(:anonymous)
            result_hash.deep_merge!(@included_hashes[name].to_transport)
          end
        end

        included_nodes.each_value do |instance|
          result_hash.deep_merge!(instance.to_transport)
        end

        edges.each do |edge|
          result_hash.deep_merge!(edge.to_transport)
        end

        nodes.each do |node|
          result_hash.deep_merge!(node.to_transport)
        end

        result_hash
      end

      base.instance_exec do
        def included_arrays
          @included_arrays ||= {}
        end

        def included_collections
          @included_collections ||= {}
        end

        def included_graphs
          @included_graphs ||= {}
        end

        def included_hashes
          @included_hashes ||= {}
        end

        def included_nodes
          @included_nodes ||= {}
        end
      end

      if RUBY_ENGINE == 'opal'
        def initialize(key)
          @class_name = self.class.name
          @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
          @store_path = [:data_state, :composable_graphs, @class_name, @key]

          @included_arrays = {}
          self.class.included_arrays.each do |name, options|
            @included_arrays[name] = if options.key?(:anonymous)
                                       options[:class].new(store_path: @store_path + [:included_arrays, name, :_inline], validated_props: @props)
                                     else
                                       options[:class].new(validated_props: @props)
                                     end
          end
          @included_collections = {}
          self.class.included_collections.each do |name, options|
            @included_collections[name] = if options.key?(:anonymous)
                                            options[:class].new(store_path: @store_path + [:included_arrays, name, :_inline], validated_props: @props)
                                          else
                                            options[:class].new(validated_props: @props)
                                          end
          end
          @included_graphs = {}
          self.class.included_graphs.each do |name, options|
            @included_graphs[name] = if options.key?(:anonymous)
                                       options[:class].new(store_path: @store_path + [:included_arrays, name, :_inline], validated_props: @props)
                                     else
                                       options[:class].new(validated_props: @props)
                                     end
          end
          @included_hashes = {}
          self.class.included_hashes.each do |name, options|
            @included_hashes[name] = if options.key?(:anonymous)
                                       options[:class].new(store_path: @store_path + [:included_arrays, name, :_inline], validated_props: @props)
                                     else
                                       options[:class].new(validated_props: @props)
                                     end
          end
        end

        def edges
          edges_as_sids.map { |edge_sid| LucidGenericEdge::Base.edge_from_sid(edge_sid) }
        end

        def edges_as_sids
          edge_sids = own_edges_as_sids
          @included_graphs.each_value { |graph| edge_sids += graph.edges_as_sids }
          edge_sids
        end

        def own_edges_as_sids
          path = @store_path + [:generic_edges]
          edge_sids = Redux.fetch_by_path(*path)
          edge_sids ? Set.new(edge_sids) : Set.new
        end

        def find_edge_by_id(edge_id)
          edges_as_sids.each do |edge_sid|
            return  LucidGenericDocument::Base.edge_from_sid(edge_sid) if edge_sid[1] == edge_id
          end
          nil
        end

        def find_node_by_id(node_id)
          nodes_as_sids.each do |node_sid|
            return  LucidGenericDocument::Base.node_from_sid(node_sid) if node_sid[1] == node_id
          end
          nil
        end

        def included_nodes
          incl_nodes = {}
          path = @store_path + [:included_nodes]
          self.class.included_nodes.each_key do |name|
            node_sid = Redux.fetch_by_path(*(path + [name]))
            incl_nodes[name] = LucidGenericDocument::Base.node_from_sid(node_sid) if node_sid
          end
          incl_nodes
        end

        def nodes
          nodes_as_sids.map { |node_sid| LucidGenericDocument::Base.node_from_sid(node_sid) }
        end

        def nodes_as_sids
          node_sids = own_nodes_as_sids
          @included_graphs.each_value { |graph| node_sids += graph.nodes_as_sids }
          @included_collections.each_value { |collection| node_sids += collection.nodes_as_sids }
          included_nodes.each_value { |node| node_sids << node.to_sid }
          node_sids
        end

        def own_nodes_as_sids
          path = @store_path + [:generic_nodes]
          node_sids = Redux.fetch_by_path(*path)
          node_sids ? Set.new(node_sids) : Set.new
        end

        def method_missing(method_name, *args, &block)
          if method_name.JS.startsWith('find_node_by_')
            attribute = method_name[13..-1] # remove 'find_node_by_'
            value = args[0]
            attribute_hash = { attribute => value }
            attribute_hash.merge!(args[1]) if args[1]
            find_node(attribute_hash)
          elsif method_name.JS.startsWith('find_edge_by_')
            attribute = method_name[13..-1] # remove 'find_edge_by_'
            value = args[0]
            attribute_hash = { attribute => value }
            attribute_hash.merge!(args[1]) if args[1]
            find_edge(attribute_hash)
          else
            super
          end
        end

        base.instance_exec do
          def include_collection(name, collection_class = nil, &block)
            included_collections[name] = if collection_class
                                           { class: collection_class }
                                         else
                                           new_class = Class.new(LucidGenericCollection::Base)
                                           new_class.instance_exec(&block)
                                           { anonymous: true, class: new_class }
                                         end
            define_method(name) do
              @included_collections[name]
            end
          end

          def include_graph(name, graph_class = nil, &block)
            included_graphs[name] = if graph_class
                                      { class: graph_class }
                                    else
                                      new_class = Class.new(LucidComposableGraph::Base)
                                      new_class.instance_exec(&block)
                                      { anonymous: true, class: new_class }
                                    end
            define_method(name) do
              @included_graphs[name]
            end
          end

          def include_node(name, node_class, &block)
            included_nodes[name] = { class: node_class, anonymous: true, block: block }
            define_method(name) do
              path = @store_path + [:included_nodes, name]
              node_sid = Redux.fetch_by_path(*path)
              node_sid ? self.class.included_nodes[name][:class].node_from_sid(node_sid) : nil
            end
          end

          def load(props_hash = {})
            validate_props(props_hash)
            instance = self.new(validated_props: Isomorfeus::Data::Props.new(props_hash))
            self.promise_load(props_hash, instance) unless instance.loaded?
            instance
          end

          def promise_load(props_hash = {}, instance = nil)
            unless instance
              validate_props(props_hash)
              instance = self.new(validated_props: Isomorfeus::Data::Props.new(props_hash))
            end

            props_json = instance.instance_variable_get(:@props_json)

            Isomorfeus::Transport.promise_send_path('Isomorfeus::Data::Handler::Generic', 'load', 'graph', self.name, props_json).then do |agent|
              if agent.processed
                agent.result
              else
                agent.processed = true
                if agent.response.key?(:error)
                  `console.error(#{agent.response[:error].to_n})`
                  raise agent.response[:error]
                end
                Isomorfeus.store.dispatch(type: 'DATA_LOAD', data: agent.full_response[:data])
                agent.result = instance
              end
            end
          end

        end
      else # RUBY_ENGINE
        unless base == LucidComposableGraph::Base
          Isomorfeus.add_valid_composable_graph_class(base)
          base.prop :pub_sub_client, default: nil
          base.prop :current_user, default: Anonymous.new
        end

        def initialize(key)
          @key = key
          @_loaded = false
          @included_arrays = {}
          @included_collections = {}
          @included_hashes = {}
          @included_graphs = {}
          @included_nodes = {}
          @class_name = self.class.name
          @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
        end

        def edges
          all_edges = @edges.to_a
          @included_graphs.each_value { |graph| all_edges += graph.edges }
          all_edges.uniq!(&:to_sid)
          all_edges
        end

        def edges_as_sids
          edges.map { |edge| [edge.class.name, edge.id] }
        end

        def own_edges_as_sids
          @edges.map(&:to_sid).uniq
        end

        def nodes
          all_nodes = @nodes.to_a
          @included_graphs.each_value { |graph| all_nodes += graph.nodes }
          @included_collections.each_value { |collection| all_nodes += collection.nodes }
          included_nodes.each_value { |node| all_nodes << node }
          all_nodes.uniq!(&:to_sid)
          all_nodes
        end

        def nodes_as_sids
          nodes.map { |node| [node.class.name, node.id] }
        end

        def own_nodes_as_sids
          @nodes.map(&:to_sid).uniq
        end

        def method_missing(method_name, *args, &block)
          if method_name.start_with?('find_node_by_')
            attribute = method_name[13..-1] # remove 'find_node_by_'
            value = args[0]
            attribute_hash = { attribute => value }
            attribute_hash.merge!(args[1]) if args[1]
            find_node(attribute_hash)
          elsif method_name.start_with?('find_edge_by_')
            attribute = method_name[13..-1] # remove 'find_edge_by_'
            value = args[0]
            attribute_hash = { attribute => value }
            attribute_hash.merge!(args[1]) if args[1]
            find_edge(attribute_hash)
          else
            super
          end
        end

        base.instance_exec do
          attr_accessor :included_nodes

          def include_collection(name, collection_class = nil, &block)
            included_collections[name] = if collection_class
                                           { class: collection_class }
                                         else
                                           new_class = Class.new(LucidGenericCollection::Base)
                                           new_class.instance_exec(&block)
                                           { anonymous: true, class: new_class }
                                         end
            define_method(name) do
              @included_collections[name]
            end
          end

          def include_graph(name, graph_class = nil, &block)
            included_graphs[name] = if graph_class
                                      { class: graph_class }
                                    else
                                      new_class = Class.new(LucidComposableGraph::Base)
                                      new_class.instance_exec(&block)
                                      { anonymous: true, class: new_class }
                                    end
            define_method(name) do
              @included_graphs[name]
            end
          end

          def include_node(name, node_class, &block)
            included_nodes[name] = { class: node_class, anonymous: true, block: block }
            define_method(name) do
              included_nodes[name]
            end
          end

          def load(props_hash = {})
            validate_props(props_hash)
            instance = self.new(validated_props: Isomorfeus::Data::Props.new(props_hash))
            instance.instance_exec do
              nodes, edges = self.class.load_query_block.call(props_hash)
              @nodes = Set.new(nodes)
              @edges = Set.new(edges)
              self.class.included_arrays.each do |name, options|
                @included_arrays[name] = options[:class].load(props_hash)
              end
              self.class.included_collections.each do |name, options|
                @included_collections[name] = options[:class].load(props_hash)
              end
              self.class.included_graphs.each do |name, options|
                @included_graphs[name] = options[:class].load(props_hash)
              end
              self.class.included_hashes.each do |name, options|
                @included_hashes[name] = options[:class].load(props_hash)
              end
              self.class.included_nodes.each do |name, options|
                result = options[:block].call(props_hash)
                @included_nodes[name] = if result.class == options[:class]
                                          result
                                        elsif result.class == Hash
                                          options[:class].new(result)
                                        end
              end
              @loaded = true
            end
            instance
          end

          def promise_load(props_hash = {}, instance = nil)
            instance = self.load(props_hash)
            result_promise = Promise.new
            result_promise.resolve(instance)
            result_promise
          end
        end
      end # RUBY_ENGINE
    end
  end
end
