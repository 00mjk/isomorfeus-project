class SimpleNode < LucidData::Document::Base
  attribute :one

  execute_load do |key:|
    new(key: key, attributes: { one: key })
  end

  execute_save do |instance:|
    instance
  end

  execute_destroy do |key:|
    true
  end
end
