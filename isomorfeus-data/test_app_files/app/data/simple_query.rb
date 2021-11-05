class SimpleQuery < LucidQuery::Base
  prop :simple_prop, class: String

  execute_query do
    { node: SimpleObject.new(key: '42', attributes: { one: props.simple_prop }) }
  end
end
