class SimpleGraph < LucidData::Graph::Base
  edges SimpleEdgeCollection
  nodes SimpleNodeCollection

  on_load do
    # nothing
  end
end
