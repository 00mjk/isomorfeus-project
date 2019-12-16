module LucidData
  module EdgeCollection
    module Finders
      def find(attribute_hash = nil, &block)
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
              found &&= (edge[k] == v)
              break unless found
            end
            return edge if found
          end
        end
        nil
      end

      def find_all(attribute_hash = nil, &block)
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
              found &&= (edge[k] == v)
              break unless found
            end
            found_edges << edge if found
          end
        end
        found_edges
      end

      def find_by_key(edge_key)
        edges.each do |edge|
          return edge if edge.key == edge_key
        end
        nil
      end

      if RUBY_ENGINE == 'opal'
        def find_by_sid(edge)
          edge_sid = edge.respond_to?(:to_sid) ? edge.to_sid : edge
          edges_as_sids.each do |sid|
            return Isomorfeus.instance_from_sid(edge_sid) if sid == edge_sid
          end
          nil
        end
      else
        def find_by_sid(edge)
          edge_sid = edge.respond_to?(:to_sid) ? edge.to_sid : edge
          edges.each do |edge|
            return edge if edge.to_sid == edge_sid
          end
          nil
        end
      end

      def find_by_from(node)
        node_sid = node.respond_to?(:to_sid) ? node.to_sid : node
        edges.each do |edge|
          return edge if edge.from_as_sid == node_sid
        end
        nil
      end

      def find_all_by_from(node)
        node_sid = node.respond_to?(:to_sid) ? node.to_sid : node
        found_edges = []
        edges.each do |edge|
          found_edges << edge if edge.from_as_sid == node_sid
        end
        found_edges
      end

      def find_by_to(node)
        node_sid = node.respond_to?(:to_sid) ? node.to_sid : node
        edges.each do |edge|
          return edge if edge.to_as_sid == node_sid
        end
        nil
      end

      def find_all_by_to(node)
        node_sid = node.respond_to?(:to_sid) ? node.to_sid : node
        found_edges = []
        edges.each do |edge|
          found_edges << edge if edge.to_as_sid == node_sid
        end
        found_edges
      end

      def find_by_target(node)
        node_sid = node.respond_to?(:to_sid) ? node.to_sid : node
        edges.each do |edge|
          return edge if edge.from_as_sid == node_sid || edge.to_as_sid == node_sid
        end
        nil
      end

      def find_all_by_target(node)
        node_sid = node.respond_to?(:to_sid) ? node.to_sid : node
        found_edges = []
        edges.each do |edge|
          found_edges << edge if edge.from_as_sid == node_sid || edge.to_as_sid == node_sid
        end
        found_edges
      end
    end
  end
end
