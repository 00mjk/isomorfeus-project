class CombinedGraph < LucidGraph::Base
  query do
    node1 = SimpleNode.new(id: 3, simple_attribute: 'simple')
    node2 = SimpleNode.new(id: 4, simple_attribute: 'simple')
    edge = SimpleEdge.new(id: 2, from: node1, to: node2, simple_attribute: 'simple')
    [[node1, node2], [edge]]
  end

  include_array :simple_array, SimpleArray
  include_collection :simple_collection, SimpleCollection
  include_graph :simple_graph, SimpleGraph
  include_hash :simple_hash, SimpleHash
  include_node :simple_node, SimpleNode do
    { id: '8', simple_attribute: 'yeah, a test' }
  end
end