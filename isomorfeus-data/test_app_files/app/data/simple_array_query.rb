class SimpleArrayQuery < LucidQuery::Base
  prop :simple_prop, class: String

  execute_query do
    { nodes: [
      SimpleObject.new(key: '42', attributes: { one: props.simple_prop }),
      SimpleObject.new(key: '43', attributes: { one: props.simple_prop }),
      SimpleObject.new(key: '44', attributes: { one: props.simple_prop }),
     ]
    }
  end
end
