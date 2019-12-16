class SimpleNode < LucidData::Document::Base
  attribute :one

  execute_load do |key:|
    { key: key, attributes: { one: key }}
  end

  on_load do
    # nothing
  end
end
