class SimpleArray < LucidData::Array::Base
  execute_load do |key:|
    new(key: key, elements: [1, 2, 3])
  end

  execute_save do |instance:|
    instance
  end

  execute_destroy do |key:|
    true
  end
end
