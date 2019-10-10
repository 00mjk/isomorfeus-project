class AllTypesComponent < LucidComponent::Base
  render do
    c = SimpleCollection.load
    DIV "collection: #{c.nodes.size}"
    g = SimpleGraph.load
    DIV "graph nodes: #{g.nodes.size}"
    DIV "graph edges: #{g.edges.size}"
    DIV 'Rendered!'
    NavigationLinks()
  end
end
