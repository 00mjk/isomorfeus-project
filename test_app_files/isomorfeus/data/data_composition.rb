class DataComposition < LucidData::Composition::Base
  compose_with :a_collection
  compose_with :a_graph
  compose_with :a_node

  execute_load do |key:|
    { key: key, parts: { a_collection: SimpleCollection.load(key: key),
                         a_graph: SimpleGraph.load(key: 1),
                         a_node: SimpleNode.load(key: 1) }}
  end
end
