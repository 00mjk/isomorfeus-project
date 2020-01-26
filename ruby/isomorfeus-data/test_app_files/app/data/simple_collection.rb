class SimpleCollection < LucidData::Collection::Base
  execute_load do |key:|
    nodes = (1..5).map do |k|
      SimpleNode.load(key: k)
    end
    { key: key, nodes: nodes }
  end

  execute_save do |key:, revision: nil, attributes: nil, documents: nil, vertexes: nil, vertices: nil, nodes: nil|
  end

  execute_destroy do |key:|
    true
  end
end
