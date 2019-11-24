class SimpleGraphX < LucidData::Graph::Base
  execute_load do |key|
    { key: key, edge_colection: SimpleEdgeCollection.load(key: key), node_collection: SimpleNodeCollection.load(key: key) }
  end

  on_load do
    # nothing
  end
end
