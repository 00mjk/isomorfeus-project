class SimpleCompressedObject < LucidObject::Base
  store_compressed quality: 1
  attribute :one
  attribute :two, index: :value
  attribute :three, index: :text
end
