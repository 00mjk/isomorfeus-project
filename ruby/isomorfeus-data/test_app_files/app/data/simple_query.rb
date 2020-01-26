class SimpleQuery < LucidData::Query::Base
  prop :simple_prop, class: String

  execute_query do |props:, current_user:, pub_sub_client:|
    { node: SimpleNode.new(key: '42', attributes: { one: props.simple_prop }) }
  end
end
