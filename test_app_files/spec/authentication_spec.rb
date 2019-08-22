require 'spec_helper'

RSpec.describe 'LucidAuthentication::Mixin' do
  context 'on server' do
    it 'can mixin' do
      result = on_server do
        class MyUser < LucidNode::Base
          include LucidAuthentication::Mixin
        end

        MyUser.ancestors.map(&:to_s)
      end
      expect(result).to include('LucidAuthentication::Mixin')
    end

    it 'can authenticate successfully' do
      result = on_server do
        promise = SimpleUser.promise_login('joe_simple', 'my_pass')
        promise.value.id
      end
      expect(result).to eq('123')
    end

    it 'can authenticate to failure, password' do
      result = on_server do
        promise = SimpleUser.promise_login('joe_simple', 'my_pas')
        promise.value
      end
      expect(result).to be_nil
    end

    it 'can authenticate to failure, user_id' do
      result = on_server do
        promise = SimpleUser.promise_login('joe_simpl', 'my_pass')
        promise.value
      end
      expect(result).to be_nil
    end
  end

  context 'on client' do
    before :all do
      @doc = visit('/')
    end

    it 'can mixin' do
      result = @doc.evaluate_ruby do
        class MyUser < LucidNode::Base
          include LucidAuthentication::Mixin
        end

        MyUser.ancestors.map(&:to_s)
      end
      expect(result).to include('LucidAuthentication::Mixin')
    end

    it 'can authenticate successfully' do
      result = @doc.await_ruby do
        Isomorfeus.instance_variable_set(:@production, false) # will fail otherwise, because connection is not secure
        SimpleUser.promise_login('joe_simple', 'my_pass').then do |user|
          user.id
        end
      end
      expect(result).to eq('123')
    end

    it 'can authenticate to failure, password' do
      result = @doc.await_ruby do
        Isomorfeus.instance_variable_set(:@production, false) # will fail otherwise, because connection is not secure
        SimpleUser.promise_login('joe_simple', 'my_pas').fail do
          true
        end
      end
      expect(result).to be true
    end

    it 'can authenticate to failure, user_id' do
      result = @doc.await_ruby do
        Isomorfeus.instance_variable_set(:@production, false) # will fail otherwise, because connection is not secure
        SimpleUser.promise_login('joe_simpl', 'my_pass').fail do
          true
        end
      end
      expect(result).to be true
    end
  end
end
