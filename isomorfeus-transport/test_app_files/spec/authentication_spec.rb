require 'spec_helper'

RSpec.describe 'LucidAuthentication::Mixin' do
  context 'on server' do
    it 'can mixin' do
      result = on_server do
        class MyUser < LucidDocument::Base
          include LucidAuthentication::Mixin
        end

        MyUser.ancestors.map(&:to_s)
      end
      expect(result).to include('LucidAuthentication::Mixin')
    end

    it 'can authenticate successfully' do
      result = on_server do
        promise = SimpleUser.promise_login(user: 'joe_simple', pass: 'my_pass')
        promise.value.key
      end
      expect(result).to eq('123')
    end

    it 'can authenticate to failure, password' do
      result = on_server do
        promise = SimpleUser.promise_login(user: 'joe_simple', pass: 'my_pas')
        promise.value
      end
      expect(result).to be_nil
    end

    it 'can authenticate to failure, user_id' do
      result = on_server do
        promise = SimpleUser.promise_login(user: 'joe_simpl', pass: 'my_pass')
        promise.value
      end
      expect(result).to be_nil
    end
  end

  context 'on client' do
    before :each do
      @page = visit('/')
    end

    it 'can mixin' do
      result = @page.eval_ruby do
        class MyUser < LucidDocument::Base
          include LucidAuthentication::Mixin
        end

        MyUser.ancestors.map(&:to_s)
      end
      expect(result).to include('LucidAuthentication::Mixin')
    end

    it 'can authenticate successfully and current_user is available' do
      @page.wait_for_navigation do
        @page.eval_ruby do
          SimpleUser.promise_login(user: 'joe_simple', pass: 'my_pass')
          nil
        end
      end
      sleep 1 # give redirect some time to set cookies
      @page.visit('/') # make sure we get proper execution context, so load page again
      result = @page.eval_ruby do
        Isomorfeus.current_user.key
      end
      expect(result).to eq('123')
    end

    it 'can authenticate to failure, password' do
      result = @page.await_ruby do
        SimpleUser.promise_login(user: 'joe_simple', pass: 'my_pas').fail do
          true
        end
      end
      expect(result).to be true
    end

    it 'can authenticate to failure, user_id' do
      result = @page.await_ruby do
        SimpleUser.promise_login(user: 'joe_simpl', pass: 'my_pass').fail do
          true
        end
      end
      expect(result).to be true
    end
  end
end
