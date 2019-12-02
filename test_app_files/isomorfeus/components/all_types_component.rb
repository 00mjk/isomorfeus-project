class AllTypesComponent < LucidComponent::Base
  render do
    @c ||= SimpleCollection.load(key: 1)
    DIV "collection: #{@c.size}"
    g = SimpleGraph.load(key: 1)
    DIV "graph nodes: #{g.nodes.size}"
    DIV "graph edges: #{g.edges.size}"
    DIV 'Rendered!'
    NavigationLinks()
  end
end
