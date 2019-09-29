class MultiCombinedGraph < LucidGenericGraph::Base
  query do
    node1 = SimpleNode.new(id: 5, simple_attribute: 'simple')
    node2 = SimpleNode.new(id: 6, simple_attribute: 'simple')
    edge = SimpleEdge.new(id: 3, from: node1, to: node2, simple_attribute: 'simple')
    [[node1, node2], [edge]]
  end

  include_array :simple_array, SimpleArray
  include_collection :simple_collection, SimpleCollection
  include_graph :simple_graph, SimpleGraph
  include_graph :combined_graph, CombinedGraph
  include_hash :simple_hash, SimpleHash
  include_node :simple_node, SimpleNode do
    { id: '9', simple_attribute: 'yeah, yeah, yeah, a test' }
  end
end
