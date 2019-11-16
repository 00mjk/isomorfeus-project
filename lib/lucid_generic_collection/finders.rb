module LucidGenericCollection
  module Finders
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

    def find_node_by_id(node_id)
      nodes_as_cids.each do |node_cid|
        return LucidGenericDocument::Base.node_from_cid(node_cid) if node_cid[1] == node_id
      end
      nil
    end
  end
end
