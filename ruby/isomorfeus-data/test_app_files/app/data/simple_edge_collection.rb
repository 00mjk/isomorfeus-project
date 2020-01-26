class SimpleEdgeCollection < LucidData::EdgeCollection::Base
  execute_load do |key:|
    edges = (1..5).map do |k|
      SimpleEdge.load(key: k)
    end
    { key: key, edges: edges }
  end

  execute_save do |key:, revision: nil, attributes: nil, edges: nil, links: nil|
  end

  execute_destroy do |key:|
    true
  end
end
