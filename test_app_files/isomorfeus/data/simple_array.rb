class SimpleArray < LucidData::Array::Base
  execute_load do |key:|
    { key: key, elements: [1, 2, 3] }
  end
end
