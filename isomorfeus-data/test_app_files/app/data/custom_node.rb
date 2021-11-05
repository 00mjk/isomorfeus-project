class CustomNode < LucidObject::Base
  attribute :one

  execute_create do
    self
  end

  execute_load do |key:|
    new(key: key, attributes: { one: key })
  end

  execute_save do
    self
  end

  execute_destroy do |key:|
    true
  end
end
