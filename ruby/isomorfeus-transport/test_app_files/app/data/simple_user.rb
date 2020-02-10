class SimpleUser < LucidData::Document::Base
  include LucidAuthentication::Mixin

  execute_login do |user:, pass:|
    if RUBY_ENGINE != 'opal'
      if user == 'joe_simple' && pass == 'my_pass'
        SimpleUser.new(key: '123')
      end
    end
  end
end
