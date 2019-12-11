module LucidData
  module Collection
    module Mixin
      def self.included(base)
        base.include(Enumerable)
        base.extend(LucidPropDeclaration::Mixin)
        base.extend(Isomorfeus::Data::GenericClassApi)
        base.include(Isomorfeus::Data::GenericInstanceApi)
        base.include(LucidData::Collection::Finders)

        base.instance_exec do
          def nodes(validate_hash = {})
            @node_conditions = validate_hash
          end
          alias document nodes
          alias vertices nodes
          alias vertexes nodes
          alias vertex nodes
          alias documents nodes
          alias node nodes

          def node_conditions
            @node_conditions
          end

          def valid_node?(node)
            return true unless @node_conditions
            Isomorfeus::Data::ElementValidator.new(self.name, node, @node_conditions).validate!
          rescue
            false
          end
          alias valid_vertex? valid_node?
          alias valid_document? valid_node?
        end

        def _validate_node(node)
          Isomorfeus::Data::ElementValidator.new(@class_name, node, @node_con).validate!
        end

        def _validate_nodes(many_nodes)
          many_nodes.each { |node| Isomorfeus::Data::ElementValidator.new(@class_name, node, @node_con).validate! }
        end

        def _collection_to_sids(collection)
          collection.map do |node|
            node.respond_to?(:to_sid) ? node.to_sid : node
          end
        end

        def _node_sid_from_arg(arg)
          if arg.respond_to?(:to_sid)
            sid = arg.to_sid
            node = arg
          else
            sid = arg
            node = Isomorfeus.instance_from_sid(sid)
          end
          [node, sid]
        end

        def to_transport
          { @class_name => { @key => nodes_as_sids }}
        end

        def included_items_to_transport
          nodes_hash = {}
          nodes.each do |node|
            nodes_hash.deep_merge!(node.to_transport)
          end
          nodes_hash
        end

        if RUBY_ENGINE == 'opal'
          def initialize(key:, revision: nil, documents: nil, vertices: nil, vertexes: nil, nodes: nil, graph: nil)
            @key = key.to_s
            @class_name = self.class.name
            @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
            @_graph = graph
            @_store_path = [:data_state, @class_name, @key]
            @_changed_collection = nil
            @_revision_store_path = [:data_state, :revision, @class_name, @key]
            @_revision = revision ? revision : Redux.fetch_by_path(*@_revision_store_path)
            @node_con = self.class.node_conditions
            @_validate_nodes = @node_con ? true : false
            nodes = documents || nodes || vertices || vertexes
            loaded = loaded?
            if nodes && loaded
              if @_validate_nodes
                nodes.each { |e| _validate_node(e) }
              end
              raw_nodes = _collection_to_sids(nodes)
              raw_collection = Redux.fetch_by_path(*@_store_path)
              if raw_collection != raw_nodes
                @_changed_collection = raw_nodes
              end
            elsif !loaded
              @_changed_collection = []
            end
          end

          def _get_collection
            return @_changed_collection if @_changed_collection
            collection = Redux.fetch_by_path(*@_store_path)
            return collection if collection
            []
          end

          def _load_from_store!
            @_changed_collection = nil
          end

          def changed?
            !!@_changed_collection
          end

          def revision
            @_revision
          end

          def nodes
            _get_collection.map { |node_sid| Isomorfeus.instance_from_sid(node_sid) }
          end
          alias vertices nodes
          alias vertexes nodes
          alias documents nodes

          def nodes_as_sids
            _get_collection
          end

          def each(&block)
            nodes.each(&block)
          end

          def method_missing(method_name, *args, &block)
            if method_name.JS.startsWith('find_document_by_') || method_name.JS.startsWith('find_node_by_')
              attribute = method_name[13..-1] # remove 'find_node_by_'
              value = args[0]
              attribute_hash = { attribute => value }
              attribute_hash.merge!(args[1]) if args[1]
              find_node(attribute_hash)
            else
              collection = _get_collection
              collection.send(method_name, *args, &block)
            end
          end

          def <<(node)
            node, sid = _node_sid_from_arg(node)
            _validate_node(node) if @_validate_nodes
            raw_collection = _get_collection
            @_changed_collection = raw_collection << sid
            self
          end

          def [](idx)
            _get_collection[idx]
          end

          def []=(idx, node)
            node, sid = _node_sid_from_arg(node)
            _validate_node(node) if @_validate_nodes
            raw_collection = _get_collection
            raw_collection[idx] = sid
            @_changed_collection = raw_collection
            node
          end

          def clear
            @_changed_collection = []
            self
          end

          def collect!(&block)
            collection = nodes
            collection.collect!(&block)
            @_changed_collection = _collection_to_sids(collection)
            self
          end

          def compact!
            raw_collection = _get_collection
            result = raw_collection.compact!
            return nil if result.nil?
            @_changed_collection = raw_collection
            self
          end

          def concat(*args)
            sids = args.map do |node|
              node, sid = _node_sid_from_arg(node)
              _validate_node(node)
              sid
            end
            raw_collection = _get_collection
            raw_collection.concat(*sids)
            @_changed_collection = raw_collection
            self
          end

          def delete(node, &block)
            node, sid = _node_sid_from_arg(node)
            raw_collection = _get_collection
            result = raw_collection.delete(sid, &block)
            return nil unless result
            @_changed_collection = raw_collection
            node
          end

          def delete_at(idx)
            raw_collection = _get_collection
            result = raw_collection.delete_at(idx)
            return nil if result.nil?
            @_changed_collection = raw_collection
            Isomorfeus.instance_from_sid(result)
          end

          def delete_if(&block)
            collection = nodes
            collection.delete_if(&block)
            @_changed_collection = _collection_to_sids(collection)
            self
          end

          def filter!(&block)
            collection = nodes
            result = collection.filter!(&block)
            return nil if result.nil?
            @_changed_collection = _collection_to_sids(collection)
            self
          end

          def insert(index, *many_nodes)
            sids = many_nodes.map do |node|
              node, sid = _node_sid_from_arg(node)
              _validate_node(node)
              sid
            end
            raw_collection = _get_collection
            raw_collection.insert(index, sids)
            @_changed_collection = raw_collection
            self
          end

          def keep_if(&block)
            collection = nodes
            collection.keep_if(&block)
            @_changed_collection = _collection_to_sids(collection)
            self
          end

          def map!(&block)
            collection = nodes
            collection.map!(&block)
            @_changed_collection = _collection_to_sids(collection)
            self
          end

          def pop(n = nil)
            raw_collection = _get_collection
            result = raw_collection.pop(n)
            @_changed_collection = raw_collection
            Isomorfeus.instance_from_sid(result)
          end

          def push(*many_nodes)
            sids = many_nodes.map do |node|
              node, sid = _node_sid_from_arg(node)
              _validate_node(node)
              sid
            end
            raw_collection = _get_collection
            raw_collection.push(*sids)
            @_changed_collection = raw_collection
            self
          end
          alias append push

          def reject!(&block)
            collection = nodes
            result = collection.reject!(&block)
            return nil if result.nil?
            @_changed_collection = _collection_to_sids(collection)
            self
          end

          def reverse!
            raw_collection = _get_collection
            raw_collection.reverse!
            @_changed_collection = raw_collection
            self
          end

          def rotate!(count = 1)
            raw_collection = _get_collection
            raw_collection.rotate!(count)
            @_changed_collection = raw_collection
            self
          end

          def select!(&block)
            collection = nodes
            result = collection.select!(&block)
            return nil if result.nil?
            @_changed_collection = _collection_to_sids(collection)
            self
          end

          def shift(n = nil)
            raw_collection = _get_collection
            result = raw_collection.shift(n)
            @_changed_collection = raw_collection
            Isomorfeus.instance_from_sid(result)
          end

          def shuffle!(*args)
            raw_collection = _get_collection
            raw_collection.shuffle!(*args)
            @_changed_collection = raw_collection
            self
          end

          def slice!(*args)
            raw_collection = _get_collection
            result = raw_collection.slice!(*args)
            @_changed_collection = raw_collection
            return nil if result.nil?
            # TODO
            result
          end

          def sort!(&block)
            collection = nodes
            collection.sort!(&block)
            @_changed_collection = _collection_to_sids(collection)
            self
          end

          def sort_by!(&block)
            collection = nodes
            collection.sort_by!(&block)
            @_changed_collection = _collection_to_sids(collection)
            self
          end

          def uniq!(&block)
            collection = nodes
            collection.uniq!(&block)
            @_changed_collection = _collection_to_sids(collection)
            self
          end

          def unshift(*many_nodes)
            sids = many_nodes.map do |node|
              node, sid = _node_sid_from_arg(node)
              _validate_node(node)
              sid
            end
            raw_collection = _get_collection
            raw_collection.unshift(*sids)
            @_changed_collection = raw_collection
            self
          end
          alias prepend unshift
        else # RUBY_ENGINE
          unless base == LucidData::Collection::Base
            Isomorfeus.add_valid_data_class(base)
            base.prop :pub_sub_client, default: nil
            base.prop :current_user, default: Anonymous.new
          end

          base.attr_accessor :graph

          base.instance_exec do
            def load(key:, pub_sub_client: nil, current_user: nil)
              nodes = instance_exec(key: key, &@_load_block)
              self.new(key: key, nodes: nodes)
            end
          end

          def initialize(key:, revision: nil, documents: nil, vertexes: nil, vertices: nil, nodes: nil, graph: nil)
            @key = key.to_s
            @class_name = self.class.name
            @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
            @graph = graph
            @_revision = revision
            @_changed = false
            @node_con = self.class.node_conditions
            @_validate_nodes = @node_con ? true : false
            nodes = documents || nodes || vertices || vertexes
            nodes = [] unless nodes
            if @_validate_nodes
              nodes.each { |n| _validate_node(n) }
            end
            nodes.each { |n| n.collection = self }
            @_raw_collection = nodes
          end

          def changed?
            @_changed
          end

          def changed!
            @graph.changed! if @graph
            @_changed = true
          end

          def revision
            @_revision
          end

          def nodes
            @_raw_collection
          end
          alias vertices nodes
          alias vertexes nodes
          alias documents nodes

          def nodes_as_sids
            @_raw_collection.map(&:to_sid)
          end

          def each(&block)
            @_raw_collection.each(&block)
          end

          def method_missing(method_name, *args, &block)
            method_name_s = method_name.to_s
            if method_name_s.start_with?('find_document_by_') || method_name_s.start_with?('find_node_by_')
              attribute = method_name_s[13..-1] # remove 'find_node_by_'
              value = args[0]
              attribute_hash = { attribute => value }
              attribute_hash.merge!(args[1]) if args[1]
              find_node(attribute_hash)
            else
              @_raw_collection.send(method_name, *args, &block)
            end
          end

          def <<(node)
            _validate_node(node) if @_validate_nodes
            changed!
            @_raw_collection << node
            node
          end

          def []=(idx, node)
            _validate_node(node) if @_validate_nodes
            changed!
            @_raw_collection[idx] = node
          end

          def clear
            changed!
            @_raw_collection = []
            self
          end

          def collect!(&block)
            changed!
            @_raw_collection.collect!(&block)
            self
          end

          def compact!
            @_raw_collection.compact!
            return nil if result.nil?
            changed!
            self
          end

          def concat(*many_nodes)
            if @_validate_nodes
              many_nodes = many_nodes.map do |node|
                _validate_node(node)
                node
              end
            end
            changed!
            @_raw_collection.concat(*many_nodes)
            self
          end

          def delete(node, &block)
            result = @_raw_collection.delete(node, &block)
            changed!
            result
          end

          def delete_at(idx)
            result = @_raw_collection.delete_at(idx)
            return nil if result.nil?
            changed!
            result
          end

          def delete_if(&block)
            @_raw_collection.delete_if(&block)
            changed!
            self
          end

          def filter!(&block)
            result = @_raw_collection.filter!(&block)
            return nil if result.nil?
            changed!
            self
          end

          def insert(idx, *many_nodes)
            if @_validate_nodes
              many_nodes = many_nodes.map do |node|
                _validate_node(node)
                node
              end
            end
            @_raw_collection.insert(idx, *many_nodes)
            changed!
            self
          end

          def keep_if(&block)
            @_raw_collection.keep_if(&block)
            changed!
            self
          end

          def map!(&block)
            @_raw_collection.map!(&block)
            changed!
            self
          end

          def pop(n = nil)
            result = @_raw_collection.pop(n)
            changed!
            result
          end

          def push(*many_nodes)
            if @_validate_nodes
              many_nodes = many_nodes.map do |node|
                _validate_node(node)
                node
              end
            end
            @_raw_collection.push(*many_nodes)
            changed!
            self
          end
          alias append push

          def reject!(&block)
            result = @_raw_collection.reject!(&block)
            return nil if result.nil?
            changed!
            self
          end

          def reverse!
            @_raw_collection.reverse!
            changed!
            self
          end

          def rotate!(count = 1)
            @_raw_collection.rotate!(count)
            changed!
            self
          end

          def select!(&block)
            result = @_raw_collection.select!(&block)
            return nil if result.nil?
            changed!
            self
          end

          def shift(n = nil)
            result = @_raw_collection.shift(n)
            changed!
            result
          end

          def shuffle!(*args)
            @_raw_collection.shuffle!(*args)
            changed!
            self
          end

          def slice!(*args)
            result = @_raw_collection.slice!(*args)
            changed!
            result
          end

          def sort!(&block)
            @_raw_collection.sort!(&block)
            changed!
            self
          end

          def sort_by!(&block)
            @_raw_collection.sort_by!(&block)
            changed!
            self
          end

          def uniq!(&block)
            @_raw_collection.uniq!(&block)
            changed!
            self
          end

          def unshift(*many_nodes)
            if @_validate_nodes
              many_nodes = many_nodes.map do |node|
                _validate_node(node)
                node
              end
            end
            @_raw_collection.unshift(*many_nodes)
            changed!
            self
          end
          alias prepend unshift
        end  # RUBY_ENGINE
      end
    end
  end
end
