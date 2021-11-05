class SimpleObject < LucidObject::Base
  attribute :one
  attribute :two, index: :value
  attribute :three, index: :text
end
