class SimpleEdge < LucidData::Edge::Base
  attribute :one

  execute_create do
    self
  end

  execute_load do |key:|
    target_key = key.to_i + 1
    target_key = 5 if target_key > 5
    new(key: key, attributes: { one: key }, from: ['SimpleNode', key], to: ['SimpleNode', target_key])
  end

  execute_save do
    self
  end

  execute_destroy do |key:|
    true
  end
end
