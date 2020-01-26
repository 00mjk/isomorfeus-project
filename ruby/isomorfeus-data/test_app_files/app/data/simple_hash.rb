class SimpleHash < LucidData::Hash::Base
  execute_load do |key:, current_user:, pub_sub_client:|
    { key: key, attributes: { one: 1, two: 2, three: 3 }}
  end

  execute_save do |key:, revision: nil, attributes: nil, current_user:, pub_sub_client:|
  end

  execute_destroy do |key:, current_user:, pub_sub_client:|
  end
end
