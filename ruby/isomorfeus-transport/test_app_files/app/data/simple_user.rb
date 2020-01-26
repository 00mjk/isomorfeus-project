class SimpleUser < LucidData::Document::Base
  include LucidAuthentication::Mixin

  authentication do |user:, pass:|
    if user == 'joe_simple' && pass == 'my_pass'
      SimpleUser.new(key: '123')
    end
  end
end
