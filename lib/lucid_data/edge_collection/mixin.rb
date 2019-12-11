module LucidData
  module EdgeCollection
    module Mixin
      def self.included(base)
        base.include(Enumerable)
        base.extend(LucidPropDeclaration::Mixin)
        base.extend(Isomorfeus::Data::GenericClassApi)
        base.include(Isomorfeus::Data::GenericInstanceApi)
        base.include(LucidData::EdgeCollection::Finders)

        base.instance_exec do
          def edges(validate_hash = {})
            @edge_conditions = validate_hash
          end
          alias links edges

          def edge_conditions
            @edge_conditions
          end

          def valid_edge?(edge)
            return true unless @edge_conditions
            Isomorfeus::Data::ElementValidator.new(self.name, edge, @edge_conditions).validate!
          rescue
            false
          end
          alias valid_link? valid_edge?
        end

        def _validate_edge(edge)
          Isomorfeus::Data::ElementValidator.new(@class_name, edge, @edge_con).validate!
        end

        def _validate_edges(many_edges)
          many_edges.each { |edge| Isomorfeus::Data::ElementValidator.new(@class_name, edge, @edge_con).validate! }
        end

        def _collection_to_sids(collection)
          collection.map do |edge|
            edge.respond_to?(:to_sid) ? edge.to_sid : edge
          end
        end

        def _edge_sid_from_arg(arg)
          if arg.respond_to?(:to_sid)
            sid = arg.to_sid
            edge = arg
          else
            sid = arg
            edge = Isomorfeus.instance_from_sid(sid)
          end
          [edge, sid]
        end

        def to_transport
          { @class_name => { @key => edges_as_sids }}
        end

        def included_items_to_transport
          edges_hash = {}
          edges.each do |edge|
            edges_hash.deep_merge!(edge.to_transport)
          end
          edges_hash
        end

        if RUBY_ENGINE == 'opal'
          def initialize(key:, revision: nil, edges: nil, links: nil, graph: nil)
            @key = key.to_s
            @class_name = self.class.name
            @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
            @_graph = graph
            @_store_path = [:data_state, @class_name, @key]
            @_changed_collection = nil
            @_revision_store_path = [:data_state, :revision, @class_name, @key]
            @_revision = revision ? revision : Redux.fetch_by_path(*@_revision_store_path)
            @edge_con = self.class.edge_conditions
            @_validate_edges = @edge_con ? true : false
            edges = edges || links
            loaded = loaded?
            if edges && loaded
              if @_validate_edges
                edges.each { |e| _validate_edges(e) }
              end
              raw_edges = _collection_to_sids(edges)
              raw_collection = Redux.fetch_by_path(*@_store_path)
              if raw_collection != raw_edges
                @_changed_collection = raw_edges
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

          def edges
            _get_collection.map { |edge_sid| Isomorfeus.instance_from_sid(edge_sid) }
          end
          alias links edges

          def edges_as_sids
            _get_collection
          end

          def each(&block)
            edges.each(&block)
          end

          def method_missing(method_name, *args, &block)
            if method_name.JS.startsWith('find_edge_by_') || method_name.JS.startsWith('find_link_by_')
              attribute = method_name[13..-1] # remove 'find_edge_by_'
              value = args[0]
              attribute_hash = { attribute => value }
              attribute_hash.merge!(args[1]) if args[1]
              find_edge(attribute_hash)
            else
              collection = _get_collection
              collection.send(method_name, *args, &block)
            end
          end

          def <<(edge)
            edge, sid = _edge_sid_from_arg(edge)
            _validate_edge(edge) if @_validate_edges
            raw_collection = _get_collection
            @_changed_collection = raw_collection << sid
            self
          end

          def [](idx)
            _get_collection[idx]
          end

          def []=(idx, edge)
            edge, sid = _edge_sid_from_arg(edge)
            _validate_edge(edge) if @_validate_edges
            raw_collection = _get_collection
            raw_collection[idx] = sid
            @_changed_collection = raw_collection
            edge
          end

          def clear
            @_changed_collection = []
            self
          end

          def collect!(&block)
            collection = edges
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
            sids = args.map do |edge|
              edge, sid = _edge_sid_from_arg(edge)
              _validate_edge(edge)
              sid
            end
            raw_collection = _get_collection
            raw_collection.concat(*sids)
            @_changed_collection = raw_collection
            self
          end

          def delete(edge, &block)
            edge, sid = _edge_sid_from_arg(edge)
            raw_collection = _get_collection
            result = raw_collection.delete(sid, &block)
            return nil unless result
            @_changed_collection = raw_collection
            edge
          end

          def delete_at(idx)
            raw_collection = _get_collection
            result = raw_collection.delete_at(idx)
            return nil if result.nil?
            @_changed_collection = raw_collection
            Isomorfeus.instance_from_sid(result)
          end

          def delete_if(&block)
            collection = edges
            collection.delete_if(&block)
            @_changed_collection = _collection_to_sids(collection)
            self
          end

          def filter!(&block)
            collection = edges
            result = collection.filter!(&block)
            return nil if result.nil?
            @_changed_collection = _collection_to_sids(collection)
            self
          end

          def insert(index, *many_edges)
            sids = many_edges.map do |edge|
              edge, sid = _edge_sid_from_arg(edge)
              _validate_edge(edge)
              sid
            end
            raw_collection = _get_collection
            raw_collection.insert(index, sids)
            @_changed_collection = raw_collection
            self
          end

          def keep_if(&block)
            collection = edges
            collection.keep_if(&block)
            @_changed_collection = _collection_to_sids(collection)
            self
          end

          def map!(&block)
            collection = edges
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

          def push(*edges)
            sids = many_edges.map do |edge|
              edge, sid = _edge_sid_from_arg(edge)
              _validate_edge(edge)
              sid
            end
            raw_collection = _get_collection
            raw_collection.push(*sids)
            @_changed_collection = raw_collection
            self
          end
          alias append push

          def reject!(&block)
            collection = edges
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
            collection = edges
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
            collection = edges
            collection.sort!(&block)
            @_changed_collection = _collection_to_sids(collection)
            self
          end

          def sort_by!(&block)
            collection = edges
            collection.sort_by!(&block)
            @_changed_collection = _collection_to_sids(collection)
            self
          end

          def uniq!(&block)
            collection = edges
            collection.uniq!(&block)
            @_changed_collection = _collection_to_sids(collection)
            self
          end

          def unshift(*many_edges)
            sids = many_edges.map do |edge|
              edge, sid = _edge_sid_from_arg(edge)
              _validate_edge(edge)
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
              edges = instance_exec(key: key, &@_load_block)
              self.new(key: key, edges: edges)
            end
          end

          def initialize(key:, revision: nil, edges: nil, links: nil, graph: nil)
            @key = key.to_s
            @class_name = self.class.name
            @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
            @graph = graph
            @_node_to_edge_cache = {}
            @_revision = revision
            @_changed = false
            @edge_con = self.class.edge_conditions
            @_validate_edges = @edge_con ? true : false
            edges = edges || links
            edges = [] unless edges
            if @_validate_edges
              edges.each { |e| _validate_edge(e) }
            end
            edges.each { |e| e.collection = self }
            @_raw_collection = edges
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

          def edges
            @_raw_collection
          end
          alias links edges

          def edges_as_sids
            @_raw_collection.map(&:to_sid)
          end

          def edges_for_node(node)
            node_sid = node.respond_to?(:to_sid) ? node.to_sid : node
            return @_node_to_edge_cache[node_sid] if @_node_to_edge_cache.key?(node_sid)
            node_edges = select do |edge|
              if edge.from.to_sid == node_sid || edge.to.to_sid == node_sid
                true
              else
                false
              end
            end
            @_node_to_edge_cache[node_sid] = node_edges
          end
          alias edges_for_vertex edges_for_node
          alias edges_for_document edges_for_node

          def update_node_to_edge_cache(edge, old_node, new_node)
            old_node_sid = old_node.to_sid
            new_node_sid = new_node.to_sid
            edge_sid = edge.to_sid
            if @_node_to_edge_cache.key?(old_node_sid)
              @_node_to_edge_cache[old_node_sid].delete_if { |node_edge| node_edge.to_sid == edge_sid }
            end
            @_node_to_edge_cache[new_node_sid].push(edge) if @_node_to_edge_cache.key?(new_node_sid)
          end

          def each(&block)
            @_raw_collection.each(&block)
          end

          def method_missing(method_name, *args, &block)
            method_name_s = method_name.to_s
            if method_name_s.start_with?('find_edge_by_') || method_name_s.start_with?('find_link_by_')
              attribute = method_name_s[13..-1] # remove 'find_edge_by_'
              value = args[0]
              attribute_hash = { attribute => value }
              attribute_hash.merge!(args[1]) if args[1]
              find_edge(attribute_hash)
            else
              @_raw_collection.send(method_name, *args, &block)
            end
          end

          def <<(edge)
            _validate_edge(edge) if @_validate_edges
            changed!
            @_raw_collection << edge
            edge
          end

          def []=(idx, edge)
            _validate_edge(edge) if @_validate_edges
            changed!
            @_raw_collection[idx] = edge
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

          def concat(*many_edges)
            if @_validate_edges
              many_edges = many_edges.map do |edge|
                _validate_edge(edge)
                edge
              end
            end
            changed!
            @_raw_collection.concat(*many_edges)
            self
          end

          def delete(edge, &block)
            result = @_raw_collection.delete(edge, &block)
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

          def insert(idx, *many_edges)
            if @_validate_edges
              many_edges = many_edges.map do |edge|
                _validate_edge(edge)
                edge
              end
            end
            @_raw_collection.insert(idx, *many_edges)
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

          def push(*many_edges)
            if @_validate_edges
              many_edges = many_edges.map do |edge|
                _validate_edge(edge)
                edge
              end
            end
            @_raw_collection.push(*many_edges)
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

          def unshift(*many_edges)
            if @_validate_edges
              many_edges = many_edges.map do |edge|
                _validate_edge(edge)
                edge
              end
            end
            @_raw_collection.unshift(*many_edges)
            changed!
            self
          end
          alias prepend unshift
        end  # RUBY_ENGINE
      end
    end
  end
end
