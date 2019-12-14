class SimpleEdgeCollection < LucidData::EdgeCollection::Base
  execute_load do |key:|
    edges = (1..5).map do |k|
      SimpleEdge.load(key: k)
    end
    { key: key, edges: edges }
  end

  on_load do
    # nothing
  end
end
