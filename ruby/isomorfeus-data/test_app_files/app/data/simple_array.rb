class SimpleArray < LucidData::Array::Base
  execute_load do |key:, current_user:, pub_sub_client:|
    { key: key, elements: [1, 2, 3] }
  end

  execute_save do |key:, revision: nil, elements:, current_user:, pub_sub_client:|
  end

  execute_destroy do |key:, current_user:, pub_sub_client:|
  end
end
