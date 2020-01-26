class SimpleArray < LucidData::Array::Base
  execute_load do |key:|
    { key: key, elements: [1, 2, 3] }
  end

  execute_save do |key:, revision: nil, elements:|
  end

  execute_destroy do |key:|
    true
  end
end
