require 'isomorfeus-data-generic'

class SimpleCollection < LucidGenericCollection::Base
  load_query do
    node1 = SimpleNode.new(id: 1, simple_attribute: 'simple')
    node2 = SimpleNode.new(id: 2, simple_attribute: 'simple')
    [node1, node2]
  end
end
