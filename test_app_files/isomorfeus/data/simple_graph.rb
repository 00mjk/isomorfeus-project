class SimpleGraph < LucidData::Graph::Base
  execute_load do |key:|
    { key: key,
      edge_collection: ['SimpleEdgeCollection', 1],
      node_collection: ['SimpleNodeCollection', 1],
      attributes: { one: key }}
  end

  on_load do
    # nothing
  end
end
