class SimpleHash < LucidData::Hash::Base
  execute_load do |key:|
    { key: key, attributes: { one: 1, two: 2, three: 3 }}
  end

  execute_save do |key:, revision: nil, attributes: nil|
  end

  execute_destroy do |key:|
    true
  end
end
