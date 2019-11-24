class SimpleEdge < LucidData::Edge::Base
  attribute :one

  execute_load do |key|
    { one: key }
  end

  on_load do
    # nothing
  end
end
