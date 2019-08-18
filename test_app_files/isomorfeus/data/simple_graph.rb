class SimpleGraph < LucidGraph::Base
  query do
    node1 = SimpleNode.new(id: 1, simple_attribute: 'simple')
    node2 = SimpleNode.new(id: 2, simple_attribute: 'simple')
    edge = SimpleEdge.new(id: 1, from: node1, to: node2, simple_attribute: 'simple')
    [[node1, node2], [edge]]
  end
end