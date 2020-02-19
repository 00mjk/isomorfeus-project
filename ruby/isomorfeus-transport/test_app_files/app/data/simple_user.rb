class SimpleUser < LucidData::Document::Base
  include LucidAuthentication::Mixin

  execute_load do |key:|
    if RUBY_ENGINE != 'opal'
      SimpleUser.new(key: key)
    end
  end

  execute_login do |user:, pass:|
    if RUBY_ENGINE != 'opal'
      if user == 'joe_simple' && pass == 'my_pass'
        SimpleUser.new(key: '123')
      end
    end
  end
end
