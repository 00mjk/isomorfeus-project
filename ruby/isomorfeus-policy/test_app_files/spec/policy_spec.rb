require 'spec_helper'

RSpec.describe 'LucidPolicy' do
  context 'on server' do
    it 'can mixin' do
      result = on_server do
        class TestClass
          include LucidPolicy::Mixin
        end
        TestClass.ancestors.map(&:to_s)
      end
      expect(result).to include("LucidPolicy::Mixin")
    end

    it 'can be inherited from' do
      result = on_server do
        class TestClassI < LucidPolicy::Base
        end
        TestClassI.ancestors.map(&:to_s)
      end
      expect(result).to include("LucidPolicy::Mixin")
      expect(result).to include("LucidPolicy::Base")
    end

    it 'can use policy_for and deny authorization' do
      result = on_server do
        class UserA
          include LucidAuthorization::Mixin
        end
        class Resource
          def run_denied
            raise "it was run though it shouldn't have"
          end

          def run_allowed
            true
          end
        end
        class UserAPolicy < LucidPolicy::Base
        end
        result_for_class  = UserA.new.authorized?(Resource)
        result_for_method = UserA.new.authorized?(Resource, :run_denied)
        [result_for_class, result_for_method]
      end
      expect(result).to eq([false, false])
    end

    it 'can use policy_for and allow for class and any method' do
      result = on_server do
        class UserB
          include LucidAuthorization::Mixin
        end
        class Resource
          def run_denied
            raise "it was run though it shouldn't have"
          end

          def run_allowed
            true
          end
        end
        class ::UserBPolicy < LucidPolicy::Base
          allow Resource
        end
        result_for_class    = UserB.new.authorized?(Resource)
        result_for_a_method = UserB.new.authorized?(Resource, :run_allowed)
        result_for_d_method = UserB.new.authorized?(Resource, :run_denied)
        [result_for_class, result_for_a_method, result_for_d_method]
      end
      expect(result).to eq([true, true, true])
    end

    it 'can use policy_for and deny for class and a specified method' do
      result = on_server do
        class UserC
          include LucidAuthorization::Mixin
        end
        class Resource
          def run_denied
            raise "it was run though it shouldn't have"
          end

          def run_allowed
            true
          end
        end
        class ::UserCPolicy < LucidPolicy::Base
          allow Resource, :run_allowed
          deny Resource, :run_denied
        end
        result_for_class    = UserC.new.authorized?(Resource)
        result_for_a_method = UserC.new.authorized?(Resource, :run_allowed)
        result_for_d_method = UserC.new.authorized?(Resource, :run_denied)
        [result_for_class, result_for_a_method, result_for_d_method]
      end
      expect(result).to eq([false, true, false])
    end

    it 'can use policy_for and deny for class and a specified method and allow for others' do
      result = on_server do
        class UserD
          include LucidAuthorization::Mixin
        end
        class Resource
          def run_denied
            raise "it was run though it shouldn't have"
          end

          def run_allowed
            true
          end
        end
        class OtherResource
          def run_allowed
            true
          end
        end
        class ::UserDPolicy < LucidPolicy::Base
          deny Resource, :run_denied
          allow others
        end
        result_for_class    = UserD.new.authorized?(OtherResource)
        result_for_a_method = UserD.new.authorized?(OtherResource, :run_allowed)
        result_for_d_method = UserD.new.authorized?(Resource, :run_denied)
        [result_for_class, result_for_a_method, result_for_d_method]
      end
      expect(result).to eq([true, true, false])
    end

    it 'can use a policy with a condition that denies' do
      result = on_server do
        class UserF
          include LucidAuthorization::Mixin

          def validated?
            false
          end
        end
        class Resource
          def run_denied
            raise "it was run though it shouldn't have"
          end

          def run_allowed
            true
          end
        end
        class UserFPolicy < LucidPolicy::Base
          allow Resource
          with_condition do |user, resource_class, resource_method|
            user.validated?
          end
        end
        result_for_class    = UserF.new.authorized?(Resource)
        result_for_a_method = UserF.new.authorized?(Resource, :run_allowed)
        result_for_d_method = UserF.new.authorized?(Resource, :run_denied)
        [result_for_class, result_for_a_method, result_for_d_method]
      end
      expect(result).to eq([false, false, false])
    end

    it 'can use a policy with a condition that allows' do
      result = on_server do
        class UserG
          include LucidAuthorization::Mixin

          def validated?
            true
          end
        end
        class Resource
          def run_denied
            raise "it was run though it shouldn't have"
          end

          def run_allowed
            true
          end
        end
        class ::UserGPolicy < LucidPolicy::Base
          allow Resource
          with_condition do |user, resource_class, resource_method|
            user.validated?
          end
        end
        result_for_class    = UserG.new.authorized?(Resource)
        result_for_a_method = UserG.new.authorized?(Resource, :run_allowed)
        result_for_d_method = UserG.new.authorized?(Resource, :run_denied)
        [result_for_class, result_for_a_method, result_for_d_method]
      end
      expect(result).to eq([true, true, true])
    end

    it 'can use a policy and refine a rule and allows' do
      result = on_server do
        class UserH
          include LucidAuthorization::Mixin

          def validated?
            true
          end
        end
        class Resource
          def run_denied
            raise "it was run though it shouldn't have"
          end

          def run_allowed
            true
          end
        end
        class ::UserHPolicy < LucidPolicy::Base
          deny Resource
          refine Resource, :run_allowed do |user, target_class, target_method|
            allow if user.validated?
            deny
          end
        end
        result_for_class    = UserH.new.authorized?(Resource)
        result_for_a_method = UserH.new.authorized?(Resource, :run_allowed)
        result_for_d_method = UserH.new.authorized?(Resource, :run_denied)
        [result_for_class, result_for_a_method, result_for_d_method]
      end
      expect(result).to eq([false, true, false])
    end

    it 'can use a policy and refine a rule and denies' do
      result = on_server do
        class UserI
          include LucidAuthorization::Mixin

          def validated?
            false
          end
        end
        class Resource
          def run_denied
            raise "it was run though it shouldn't have"
          end

          def run_allowed
            true
          end
        end
        class ::UserIPolicy < LucidPolicy::Base
          allow Resource
          refine Resource, :run_denied do |user, target_class, target_method|
            allow if user.validated?
            deny
          end
        end
        result_for_class    = UserI.new.authorized?(Resource)
        result_for_a_method = UserI.new.authorized?(Resource, :run_allowed)
        result_for_d_method = UserI.new.authorized?(Resource, :run_denied)
        [result_for_class, result_for_a_method, result_for_d_method]
      end
      expect(result).to eq([true, true, false])
    end
  end

  context 'on client' do
    before :each do
      @doc = visit('/')
    end

    it 'can mixin' do
      result = @doc.evaluate_ruby do
        class TestClass
          include LucidPolicy::Mixin
        end
        TestClass.ancestors.map(&:to_s)
      end
      expect(result).to include("LucidPolicy::Mixin")
    end

    it 'can be inherited from' do
      result = @doc.evaluate_ruby do
        class TestClassI < LucidPolicy::Base
        end
        TestClassI.ancestors.map(&:to_s)
      end
      expect(result).to include("LucidPolicy::Mixin")
      expect(result).to include("LucidPolicy::Base")
    end

    it 'can use policy_for and allow for class and any method' do
      result = @doc.evaluate_ruby do
        class UserB
          include LucidAuthorization::Mixin
        end
        class Resource
          def run_denied
            raise "it was run though it shouldn't have"
          end

          def run_allowed
            true
          end
        end
        class UserBPolicy < LucidPolicy::Base
          allow Resource
        end
        result_for_class    = UserB.new.authorized?(Resource)
        result_for_a_method = UserB.new.authorized?(Resource, :run_allowed)
        result_for_d_method = UserB.new.authorized?(Resource, :run_denied)
        [result_for_class, result_for_a_method, result_for_d_method]
      end
      expect(result).to eq([true, true, true])
    end

    it 'can use policy_for and deny for class and a specified method' do
      result = @doc.evaluate_ruby do
        class UserC
          include LucidAuthorization::Mixin
        end
        class Resource
          def run_denied
            raise "it was run though it shouldn't have"
          end

          def run_allowed
            true
          end
        end
        class UserCPolicy < LucidPolicy::Base
          allow Resource, :run_allowed
          deny Resource, :run_denied
        end
        result_for_class    = UserC.new.authorized?(Resource)
        result_for_a_method = UserC.new.authorized?(Resource, :run_allowed)
        result_for_d_method = UserC.new.authorized?(Resource, :run_denied)
        [result_for_class, result_for_a_method, result_for_d_method]
      end
      expect(result).to eq([false, true, false])
    end

    it 'can use policy_for and deny for class and a specified method and allow for others' do
      result = @doc.evaluate_ruby do
        class UserD
          include LucidAuthorization::Mixin
        end
        class Resource
          def run_denied
            raise "it was run though it shouldn't have"
          end

          def run_allowed
            true
          end
        end
        class OtherResource
          def run_allowed
            true
          end
        end
        class UserDPolicy < LucidPolicy::Base
          deny Resource, :run_denied
          allow others
        end
        result_for_class    = UserD.new.authorized?(OtherResource)
        result_for_a_method = UserD.new.authorized?(OtherResource, :run_allowed)
        result_for_d_method = UserD.new.authorized?(Resource, :run_denied)
        [result_for_class, result_for_a_method, result_for_d_method]
      end
      expect(result).to eq([true, true, false])
    end

    it 'can use a policy with a condition that denies' do
      result = @doc.evaluate_ruby do
        class UserF
          include LucidAuthorization::Mixin

          def validated?
            false
          end
        end
        class Resource
          def run_denied
            raise "it was run though it shouldn't have"
          end

          def run_allowed
            true
          end
        end
        class UserFPolicy < LucidPolicy::Base
          allow Resource
          with_condition do |user, resource_class, resource_method|
            user.validated?
          end
        end
        result_for_class    = UserF.new.authorized?(Resource)
        result_for_a_method = UserF.new.authorized?(Resource, :run_allowed)
        result_for_d_method = UserF.new.authorized?(Resource, :run_denied)
        [result_for_class, result_for_a_method, result_for_d_method]
      end
      expect(result).to eq([false, false, false])
    end

    it 'can use a policy with a condition that allows' do
      result = @doc.evaluate_ruby do
        class UserG
          include LucidAuthorization::Mixin

          def validated?
            true
          end
        end
        class Resource
          def run_denied
            raise "it was run though it shouldn't have"
          end

          def run_allowed
            true
          end
        end
        class UserGPolicy < LucidPolicy::Base
          allow Resource
          with_condition do |user, resource_class, resource_method|
            user.validated?
          end
        end
        result_for_class    = UserG.new.authorized?(Resource)
        result_for_a_method = UserG.new.authorized?(Resource, :run_allowed)
        result_for_d_method = UserG.new.authorized?(Resource, :run_denied)
        [result_for_class, result_for_a_method, result_for_d_method]
      end
      expect(result).to eq([true, true, true])
    end

    it 'can use a policy and refine a rule and allows' do
      result = @doc.evaluate_ruby do
        class UserH
          include LucidAuthorization::Mixin

          def validated?
            true
          end
        end
        class Resource
          def run_denied
            raise "it was run though it shouldn't have"
          end

          def run_allowed
            true
          end
        end
        class UserHPolicy < LucidPolicy::Base
          deny Resource
          refine Resource, :run_allowed do |user, target_class, target_method|
            allow if user.validated?
            deny
          end
        end
        result_for_class    = UserH.new.authorized?(Resource)
        result_for_a_method = UserH.new.authorized?(Resource, :run_allowed)
        result_for_d_method = UserH.new.authorized?(Resource, :run_denied)
        [result_for_class, result_for_a_method, result_for_d_method]
      end
      expect(result).to eq([false, true, false])
    end

    it 'can use a policy and refine a rule and denies' do
      result = @doc.evaluate_ruby do
        class UserI
          include LucidAuthorization::Mixin

          def validated?
            false
          end
        end
        class Resource
          def run_denied
            raise "it was run though it shouldn't have"
          end

          def run_allowed
            true
          end
        end
        class UserIPolicy < LucidPolicy::Base
          allow Resource
          refine Resource, :run_denied do |user, target_class, target_method|
            allow if user.validated?
            deny
          end
        end
        result_for_class    = UserI.new.authorized?(Resource)
        result_for_a_method = UserI.new.authorized?(Resource, :run_allowed)
        result_for_d_method = UserI.new.authorized?(Resource, :run_denied)
        [result_for_class, result_for_a_method, result_for_d_method]
      end
      expect(result).to eq([true, true, false])
    end
  end
end
