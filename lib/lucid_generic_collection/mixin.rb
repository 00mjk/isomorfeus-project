module LucidGenericCollection
  module Mixin
    def self.included(base)
      if RUBY_ENGINE != 'opal'
        Isomorfeus.add_valid_generic_collection_class(base) unless base == LucidGenericCollection::Base
      end

      base.extend(LucidPropDeclaration::Mixin)

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
        if inline
          { '_inline' => { @props_json => nodes_as_cids }}
        else
          { 'generic_collections' => { @class_name => { @props_json => nodes_as_cids }}}
        end
      end

      def included_items_to_transport
        nodes_hash = {}
        nodes.each do |node|
          nodes_hash.deep_merge!(node.to_transport)
        end
        nodes_hash
      end

      base.instance_exec do
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
          @store_path = store_path
          @class_name = self.class.name
          @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
          @store_path = store_path ? store_path : [:data_state, :generic_collections, @class_name, @props_json]
        end

        def loaded?
          Redux.fetch_by_path(*@store_path) ? true : false
        end

        def find_node_by_id(node_id)
          nodes_as_cids.each do |node_cid|
            return LucidGenericDocument::Base.node_from_cid(node_cid) if node_cid[1] == node_id
          end
          nil
        end

        def nodes
          # maybe use a node cache, maybe not:
          # - pro node cache: maybe faster
          # - contra node cache: js garbage collection fails because references are kept forever, memory usage just grows and grows
          nodes_as_cids.map { |node_cid| LucidGenericDocument::Base.node_from_cid(node_cid) }
        end

        def nodes_as_cids
          node_cids = Redux.fetch_by_path(*@store_path)
          node_cids ? node_cids : []
        end

        def method_missing(method_name, *args, &block)
          if method_name.JS.startsWith('find_node_by_')
            attribute = method_name[13..-1] # remove 'find_node_by_'
            value = args[0]
            attribute_hash = { attribute => value }
            attribute_hash.merge!(args[1]) if args[1]
            find_node(attribute_hash)
          else
            super
          end
        end

        base.instance_exec do
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

            Isomorfeus::Transport.promise_send_path('Isomorfeus::Data::Handler::Generic', 'collection', self.name, 'load', props_json).then do |agent|
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
        unless base == LucidGenericCollection::Base
          base.prop :pub_sub_client, default: nil
          base.prop :current_user, default: nil
        end

        def initialize(store_path: nil, validated_props: nil)
          @props = validated_props
          @props_json = @props.to_json if @props
          @loaded = false
          @class_name = self.class.name
          @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
        end

        def loaded?
          @loaded
        end

        def method_missing(method_name, *args, &block)
          if method_name.start_with?('find_node_by_')
            attribute = method_name[13..-1] # remove 'find_node_by_'
            value = args[0]
            attribute_hash = { attribute => value }
            attribute_hash.merge!(args[1]) if args[1]
            find_node(attribute_hash)
          else
            super
          end
        end

        def nodes_as_cids
          nodes.map { |node| node.to_cid }
        end

        base.instance_exec do
          attr_reader :nodes

          def load(props_hash = {})
            validate_props(props_hash)
            instance = self.new(validated_props: Isomorfeus::Data::Props.new(props_hash))
            instance.instance_exec do
              @nodes = self.class.load_query_block.call(props_hash)
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
      end  # RUBY_ENGINE
    end
  end
end
