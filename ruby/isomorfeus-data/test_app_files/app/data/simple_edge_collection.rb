class SimpleEdgeCollection < LucidData::EdgeCollection::Base
  execute_load do |key:|
    edges = (1..5).map do |k|
      SimpleEdge.load(key: k)
    end
    new(key: key, edges: edges)
  end

  execute_save do |instance:|
    instance
  end

  execute_destroy do |key:|
    true
  end
end
