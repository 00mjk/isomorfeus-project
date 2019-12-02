class SimpleUser < LucidData::Document::Base
  include LucidAuthentication::Mixin

  authentication do |user_id, user_pass|
    if user_id == 'joe_simple' && user_pass == 'my_pass'
      SimpleUser.new(key: '123')
    end
  end
end
