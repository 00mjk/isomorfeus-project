class SimpleComposition < LucidData::Composition::Base
  compose_with :a_collection
  compose_with :a_graph
  compose_with :a_node
  compose_with :a_array
  compose_with :a_hash

  execute_load do |key:|
    { key: key, parts: { a_collection: SimpleCollection.load(key: key),
                         a_graph: SimpleGraph.load(key: key),
                         a_node: SimpleNode.load(key: key),
                         a_array: SimpleArray.load(key: key),
                         a_hash: SimpleHash.load(key: key) }}
  end

  execute_save do |key:, revision: nil, parts:, attributes:|
  end

  execute_destroy do |key:|
    true
  end
end
