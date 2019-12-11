class SimpleGraph < LucidData::Graph::Base
  execute_load do |key:|
    if RUBY_ENGINE != 'opal'
    { key: key,
      edges: SimpleEdgeCollection.load(key: 1),
      nodes: SimpleNodeCollection.load(key: 1),
      attributes: { one: key }}
    end
  end

  on_load do
    # nothing
  end
end
