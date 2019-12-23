class SimpleNode < LucidData::Document::Base
  attribute :one

  execute_load do |key:|
    { key: key, attributes: { one: key }}
  end

  execute_query do |props:, current_user:, pub_sub_client:|
  end

  execute_save do |key:, revision: nil, attributes: nil, current_user:, pub_sub_client:|
  end

  execute_destroy do |key:, current_user:, pub_sub_client:|
  end
end
