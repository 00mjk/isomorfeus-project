module LucidData
  module Graph
    module Finders
      def find_node(attribute_hash = nil, &block)
        @_node_collections.each_value do |collection|
          node = collection.find(attribute_hash, &block)
          return node if node
        end
        nil
      end
      alias find_document find_node
      alias find_vertex find_node

      def find_nodes(attribute_hash = nil, &block)
        found_nodes = []
        @_node_collections.each_value do |collection|
          nodes = collection.find_all(attribute_hash, &block)
          found_nodes.push(*nodes)
        end
        found_nodes
      end
      alias find_documents find_nodes
      alias find_vertexes find_nodes
      alias find_vertices find_nodes

      def find_node_by_key(node_key)
        @_node_collections.each_value do |collection|
          node = collection.find_by_key(node_key)
          return node if node
        end
        nil
      end
      alias find_document_by_key find_node_by_key
      alias find_vertex_by_key find_node_by_key

      def find_node_by_sid(node)
        @_node_collections.each_value do |collection|
          node = collection.find_by_sid(node)
          return node if node
        end
        nil
      end
      alias find_document_by_sid find_node_by_sid
      alias find_vertex_by_sid find_node_by_sid

      def find_edge(attribute_hash = nil, &block)
        @_edge_collections.each_value do |collection|
          edge = collection.find(attribute_hash, &block)
          return edge if edge
        end
        nil
      end
      alias find_link find_edge

      def find_edges(attribute_hash = nil, &block)
        found_edges = []
        @_edge_collections.each_value do |collection|
          edges = collection.find_all(attribute_hash, &block)
          found_edges.push(*edges)
        end
        found_edges
      end
      alias find_links find_edges

      def find_edge_by_key(edge_key)
        @_edge_collections.each_value do |collection|
          edge = collection.find_by_key(edge_key)
          return edge if edge
        end
        nil
      end
      alias find_link_by_key find_edge_by_key

      def find_edge_by_sid(edge)
        @_edge_collections.each_value do |collection|
          edge = collection.find_by_sid(edge)
          return edge if edge
        end
        nil
      end
      alias find_link_by_key find_edge_by_key

      def find_edge_by_from(node)
        @_edge_collections.each_value do |collection|
          edge = collection.find_by_from(node)
          return edge if edge
        end
        nil
      end
      alias find_link_by_from find_edge_by_from

      def find_edge_by_to(node)
        @_edge_collections.each_value do |collection|
          edge = collection.find_by_to(node)
          return edge if edge
        end
        nil
      end
      alias find_link_by_to find_edge_by_to

      def find_edge_by_target(node)
        @_edge_collections.each_value do |collection|
          edge = collection.find_by_target(node)
          return edge if edge
        end
        nil
      end
      alias find_link_by_target find_edge_by_target

      def find_edges_by_from(node)
        found_edges = []
        @_edge_collections.each_value do |collection|
          coll_edges = collection.find_all_by_from(node)
          found_edges.push(*coll_edges)
        end
        found_edges
      end
      alias find_links_by_from find_edges_by_from

      def find_edges_by_to(node)
        found_edges = []
        @_edge_collections.each_value do |collection|
          coll_edges = collection.find_all_by_to(node)
          found_edges.push(*coll_edges)
        end
        found_edges
      end
      alias find_links_by_to find_edges_by_to

      def find_edges_by_target(node)
        found_edges = []
        @_edge_collections.each_value do |collection|
          coll_edges = collection.find_all_by_target(node)
          found_edges.push(*coll_edges)
        end
        found_edges
      end
      alias find_links_by_target find_edges_by_target
    end
  end
end
