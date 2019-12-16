module LucidData
  module Collection
    module Finders
      def find(attribute_hash = nil, &block)
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

      def find_all(attribute_hash = nil, &block)
        found_nodes = []
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

      def find_by_key(node_key)
        nodes.each do |node|
          return node if node.key == node_key
        end
        nil
      end

      if RUBY_ENGINE == 'opal'
        def find_by_sid(node)
          node_sid = node.respond_to?(:to_sid) ? node.to_sid : node
          nodes_as_sids.each do |sid|
            return Isomorfeus.instance_from_sid(node_sid) if sid == node_sid
          end
          nil
        end
      else
        def find_by_sid(node)
          node_sid = node.respond_to?(:to_sid) ? node.to_sid : node
          nodes.each do |node|
            return node if node.to_sid == node_sid
          end
          nil
        end
      end
    end
  end
end
