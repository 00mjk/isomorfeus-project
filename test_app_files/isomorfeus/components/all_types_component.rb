class AllTypesComponent < LucidComponent::Base
  render do
    a = SimpleArray.load
    DIV "array: #{a.items}"
    c = SimpleCollection.load
    DIV "collection: #{c.nodes.size}"
    g = SimpleGraph.load
    DIV "graph nodes: #{g.nodes.size}"
    DIV "graph edges: #{g.edges.size}"
    h = SimpleHash.load
    DIV "hash: #{h.to_h}"
    DIV 'Rendered!'
    NavigationLinks()
  end
end