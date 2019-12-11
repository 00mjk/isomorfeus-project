module LucidData::ComposableGraph
  module Finders
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
  end
end
