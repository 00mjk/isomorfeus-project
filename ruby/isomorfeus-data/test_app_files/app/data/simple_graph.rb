class SimpleGraph < LucidData::Graph::Base
  attribute :one

  execute_load do |key:|
    if RUBY_ENGINE != 'opal'
      new(key: key,
          edges: SimpleEdgeCollection.load(key: 1),
          nodes: SimpleCollection.load(key: 1),
          attributes: { one: key })
    end
  end

  execute_save do |instance:|
    instance
  end

  execute_destroy do |key:|
    true
  end
end
