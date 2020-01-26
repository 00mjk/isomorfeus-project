class SimpleNode < LucidData::Document::Base
  attribute :one

  execute_load do |key:|
    { key: key, attributes: { one: key }}
  end

  execute_save do |key:, revision: nil, attributes: nil|
  end

  execute_destroy do |key:|
    true
  end
end
