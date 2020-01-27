class SimpleHash < LucidData::Hash::Base
  execute_load do |key:|
    new(key: key, attributes: { one: 1, two: 2, three: 3 })
  end

  execute_save do |instance:|
    instance
  end

  execute_destroy do |key:|
    true
  end
end
