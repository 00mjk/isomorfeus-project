class SimpleCollection < LucidData::Collection::Base
  execute_load do |key:, current_user:, pub_sub_client:|
    nodes = (1..5).map do |k|
      SimpleNode.load(key: k)
    end
    { key: key, nodes: nodes }
  end

  execute_save do |key:, revision: nil, attributes: nil, documents: nil, vertexes: nil, vertices: nil, nodes: nil, current_user:, pub_sub_client:|
  end

  execute_destroy do |key:, current_user:, pub_sub_client:|
  end
end
