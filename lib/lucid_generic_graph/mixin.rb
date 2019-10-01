module LucidGenericGraph
  module Mixin
    def self.included(base)
      if RUBY_ENGINE != 'opal'
        Isomorfeus.add_valid_graph_class(base) unless base == LucidGenericGraph::Base
      end

      base.extend(LucidPropDeclaration::Mixin)

      def find_edge(attribute_hash = nil, &block)
        if block_given?
          edges.each do |edge|
            return edge if block.call(edge)
          end
        else
          edge_class = attribute_hash.delete(:class)
          is_a_module = attribute_hash.delete(:is_a)
          edges.each do |edge|
            if edge_class
              next unless edge.class == edge_class
            end
            if is_a_module
              next unless edge.is_a?(is_a_module)
            end
            found = true
            attribute_hash.each do |k,v|
              found &&= (node[k] == v)
              break unless found
            end
            return edge if found
          end
        end
        nil
      end

      def find_edges(attribute_hash = nil, &block)
        found_edges = Set.new
        if block_given?
          edges.each do |edge|
            found_edges << edge if block.call(edge)
          end
        else
          edge_class = attribute_hash.delete(:class)
          is_a_module = attribute_hash.delete(:is_a)
          edges.each do |edge|
            if edge_class
              next unless edge.class == edge_class
            end
            if is_a_module
              next unless edge.is_a?(is_a_module)
            end
            found = true
            attribute_hash.each do |k,v|
              found &&= (node[k] == v)
              break unless found
            end
            found_edges << edge if found
          end
        end
        found_edges
      end

      def find_node(attribute_hash = nil, &block)
        if block_given?
          nodes.each do |node|
            return node if block.call(node)
          end
        else
          node_class = attribute_hash.delete(:class)
          is_a_module = attribute_hash.delete(:is_a)
          nodes.each do |node|
            if node_class
              next unless node.class == node_class
            end
            if is_a_module
              next unless node.is_a?(is_a_module)
            end
            found = true
            attribute_hash.each do |k,v|
              found &&= (node[k] == v)
              break unless found
            end
            return node if found
          end
        end
        nil
      end

      def find_nodes(attribute_hash = nil, &block)
        found_nodes = Set.new
        if block_given?
          nodes.each do |node|
            found_nodes << node if block.call(node)
          end
        else
          node_class = attribute_hash.delete(:class)
          is_a_module = attribute_hash.delete(:is_a)
          nodes.each do |node|
            if node_class
              next unless node.class == node_class
            end
            if is_a_module
              next unless node.is_a?(is_a_module)
            end
            found = true
            attribute_hash.each do |k,v|
              found &&= (node[k] == v)
              break unless found
            end
            found_nodes << node if found
          end
        end
        found_nodes
      end

      def to_gid
        [@class_name, @props_json]
      end

      def to_transport(inline: false)
        items_hash = {}
        own_edge_cids = own_edges_as_cids
        own_node_cids = own_nodes_as_cids
        items_hash['generic_edges'] = own_edge_cids.to_a if own_edge_cids.size > 0
        items_hash['generic_nodes'] = own_node_cids.to_a if own_node_cids.size > 0

        if @included_arrays.size > 0
          items_hash['included_arrays'] = {}
          @included_arrays.each do |name, instance|
            items_hash['included_arrays'][name.to_s] = if self.class.included_arrays[name].key?(:anonymous)
                                                    instance.to_transport(inline: true)
                                                  else
                                                    instance.to_gid
                                                  end
          end
        end

        if @included_collections.size > 0
          items_hash['included_collections'] = {}
          @included_collections.each do |name, instance|
            items_hash['included_collections'][name.to_s] = if self.class.included_collections[name].key?(:anonymous)
                                                         instance.to_transport(inline: true)
                                                       else
                                                         instance.to_gid
                                                       end
          end
        end

        if @included_graphs.size > 0
          items_hash['included_graphs'] = {}
          @included_graphs.each do |name, instance|
            items_hash['included_graphs'][name.to_s] = if self.class.included_graphs[name].key?(:anonymous)
                                                    instance.to_transport(inline: true)
                                                  else
                                                    instance.to_gid
                                                  end
          end
        end

        if @included_hashes.size > 0
          items_hash['included_hashes'] = {}
          @included_hashes.each do |name, instance|
            items_hash['included_hashes'][name.to_s] = if self.class.included_hashes[name].key?(:anonymous)
                                                    instance.to_transport(inline: true)
                                                  else
                                                    instance.to_gid
                                                  end
          end
        end

        incl_nodes = included_nodes
        if incl_nodes.size > 0
          items_hash['included_nodes'] = {}
          incl_nodes.each do |name, instance|
            items_hash['included_nodes'][name.to_s] = instance.to_cid
          end
        end

        if inline
          { '_inline' => { @props_json => items_hash }}
        else
          { 'generic_graphs' => { @class_name => { @props_json => items_hash }}}
        end
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

        def on_load_block
          @on_load_block
        end

        def load_query_block
          @load_query_block
        end
      end

      if RUBY_ENGINE == 'opal'
        def initialize(store_path: nil, validated_props: nil)
          @props = validated_props
          @props_json = @props.to_json if @props
          @class_name = self.class.name
          @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
          @store_path = store_path ? store_path : [:data_state, :generic_graphs, @class_name, @props_json]

          @included_arrays = {}
          self.class.included_arrays.each do |name, options|
            @included_arrays[name] = if options.key?(:anonymous)
                                       options[:class].new(store_path: @store_path + [:included_arrays, name, :_inline],
                                                           validated_props: @props)
                                     else
                                       options[:class].new(validated_props: @props)
                                     end
          end
          @included_collections = {}
          self.class.included_collections.each do |name, options|
            @included_collections[name] = if options.key?(:anonymous)
                                            options[:class].new(store_path: @store_path + [:included_arrays, name, :_inline],
                                                                validated_props: @props)
                                          else
                                            options[:class].new(validated_props: @props)
                                          end
          end
          @included_graphs = {}
          self.class.included_graphs.each do |name, options|
            @included_graphs[name] = if options.key?(:anonymous)
                                       options[:class].new(store_path: @store_path + [:included_arrays, name, :_inline],
                                                           validated_props: @props)
                                     else
                                       options[:class].new(validated_props: @props)
                                     end
          end
          @included_hashes = {}
          self.class.included_hashes.each do |name, options|
            @included_hashes[name] = if options.key?(:anonymous)
                                       options[:class].new(store_path: @store_path + [:included_arrays, name, :_inline],
                                                           validated_props: @props)
                                     else
                                       options[:class].new(validated_props: @props)
                                     end
          end
        end

        def loaded?
          Redux.fetch_by_path(*@store_path) ? true : false
        end

        def edges
          edges_as_cids.map { |edge_cid| LucidGenericEdge::Base.edge_from_cid(edge_cid) }
        end

        def edges_as_cids
          edge_cids = own_edges_as_cids
          @included_graphs.each_value { |graph| edge_cids += graph.edges_as_cids }
          edge_cids
        end

        def own_edges_as_cids
          path = @store_path + [:generic_edges]
          edge_cids = Redux.fetch_by_path(*path)
          edge_cids ? Set.new(edge_cids) : Set.new
        end

        def find_edge_by_id(edge_id)
          edges_as_cids.each do |edge_cid|
            return  LucidGenericNode::Base.edge_from_cid(edge_cid) if edge_cid[1] == edge_id
          end
          nil
        end

        def find_node_by_id(node_id)
          nodes_as_cids.each do |node_cid|
            return  LucidGenericNode::Base.node_from_cid(node_cid) if node_cid[1] == node_id
          end
          nil
        end

        def included_nodes
          incl_nodes = {}
          path = @store_path + [:included_nodes]
          self.class.included_nodes.each_key do |name|
            node_cid = Redux.fetch_by_path(*(path + [name]))
            incl_nodes[name] = LucidGenericNode::Base.node_from_cid(node_cid) if node_cid
          end
          incl_nodes
        end

        def nodes
          nodes_as_cids.map { |node_cid| LucidGenericNode::Base.node_from_cid(node_cid) }
        end

        def nodes_as_cids
          node_cids = own_nodes_as_cids
          @included_graphs.each_value { |graph| node_cids += graph.nodes_as_cids }
          @included_collections.each_value { |collection| node_cids += collection.nodes_as_cids }
          included_nodes.each_value { |node| node_cids << node.to_cid }
          node_cids
        end

        def own_nodes_as_cids
          path = @store_path + [:generic_nodes]
          node_cids = Redux.fetch_by_path(*path)
          node_cids ? Set.new(node_cids) : Set.new
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
          def include_array(name, array_class = nil, &block)
            included_arrays[name] = if array_class
                                      { class: array_class }
                                    else
                                      new_class = Class.new(LucidArray::Base)
                                      new_class.instance_exec(&block)
                                      { anonymous: true, class: new_class }
                                    end
            define_method(name) do
              @included_arrays[name]
            end
          end

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
                                      new_class = Class.new(LucidGenericGraph::Base)
                                      new_class.instance_exec(&block)
                                      { anonymous: true, class: new_class }
                                    end
            define_method(name) do
              @included_graphs[name]
            end
          end

          def include_hash(name, hash_class = nil, &block)
            included_hashes[name] = if hash_class
                                      { class: hash_class }
                                    else
                                      new_class = Class.new(LucidHash::Base)
                                      new_class.instance_exec(&block)
                                      { anonymous: true, class: new_class }
                                    end
            define_method(name) do
              @included_hashes[name]
            end
          end

          def include_node(name, node_class, &block)
            included_nodes[name] = { class: node_class, anonymous: true, block: block }
            define_method(name) do
              path = @store_path + [:included_nodes, name]
              node_cid = Redux.fetch_by_path(*path)
              node_cid ? self.class.included_nodes[name][:class].node_from_cid(node_cid) : nil
            end
          end

          def load(props_hash = {})
            validate_props(props_hash)
            instance = self.new(validated_props: Isomorfeus::Data::Props.new(props_hash))
            self.promise_load(props_hash, instance) unless instance.loaded?
            instance
          end

          def on_load(&block)
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

          def load_query; end
        end
      else # RUBY_ENGINE
        unless base == LucidGenericGraph::Base
          base.prop :pub_sub_client, default: nil
          base.prop :current_user, default: nil
        end

        def initialize(store_path: nil, validated_props: nil)
          @props = validated_props
          @props_json = @props.to_json if @props
          @loaded = false
          @included_arrays = {}
          @included_collections = {}
          @included_hashes = {}
          @included_graphs = {}
          @included_nodes = {}
          @class_name = self.class.name
          @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
        end

        def loaded?
          @loaded
        end

        def edges
          all_edges = @edges.to_a
          @included_graphs.each_value { |graph| all_edges += graph.edges }
          all_edges.uniq!(&:to_cid)
          all_edges
        end

        def edges_as_cids
          edges.map { |edge| [edge.class.name, edge.id] }
        end

        def own_edges_as_cids
          @edges.map(&:to_cid).uniq
        end

        def nodes
          all_nodes = @nodes.to_a
          @included_graphs.each_value { |graph| all_nodes += graph.nodes }
          @included_collections.each_value { |collection| all_nodes += collection.nodes }
          included_nodes.each_value { |node| all_nodes << node }
          all_nodes.uniq!(&:to_cid)
          all_nodes
        end

        def nodes_as_cids
          nodes.map { |node| [node.class.name, node.id] }
        end

        def own_nodes_as_cids
          @nodes.map(&:to_cid).uniq
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

          def include_array(name, array_class = nil, &block)
            included_arrays[name] = if array_class
                                           { class: array_class }
                                         else
                                           new_class = Class.new(LucidArray::Base)
                                           new_class.instance_exec(&block)
                                           { anonymous: true, class: new_class }
                                         end
            define_method(name) do
              @included_arrays[name]
            end
          end

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
                                      new_class = Class.new(LucidGenericGraph::Base)
                                      new_class.instance_exec(&block)
                                      { anonymous: true, class: new_class }
                                    end
            define_method(name) do
              @included_graphs[name]
            end
          end

          def include_hash(name, hash_class = nil, &block)
            included_hashes[name] = if hash_class
                                      { class: hash_class }
                                    else
                                      new_class = Class.new(LucidHash::Base)
                                      new_class.instance_exec(&block)
                                      { anonymous: true, class: new_class }
                                    end
            define_method(name) do
              @included_hashes[name]
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

          def on_load(&block)
            @on_load_block = block
          end

          def promise_load(props_hash = {}, instance = nil)
            instance = self.load(props_hash)
            result_promise = Promise.new
            result_promise.resolve(instance)
            result_promise
          end

          def load_query(&block)
            @load_query_block = block
          end
        end
      end # RUBY_ENGINE
    end
  end
end
