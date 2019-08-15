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
        end
        class Resource
          def run_denied
            raise "it was run though it shouldnt have"
          end
          def run_allowed
            true
          end
        end
        class TestClassPolicyA < LucidPolicy::Base
          policy_for UserA
        end
        result_for_class = UserA.new.authorized?(Resource)
        result_for_method = UserA.new.authorized?(Resource, :run_denied)
        [result_for_class, result_for_method]
      end
      expect(result).to eq([false, false])
    end

    it 'can use policy_for and allow for class and any method' do
      result = on_server do
        class UserB
        end
        class Resource
          def run_denied
            raise "it was run though it shouldnt have"
          end
          def run_allowed
            true
          end
        end
        class TestClassPolicyB < LucidPolicy::Base
          policy_for UserB
          allow Resource
        end
        result_for_class = UserB.new.authorized?(Resource)
        result_for_a_method = UserB.new.authorized?(Resource, :run_allowed)
        result_for_d_method = UserB.new.authorized?(Resource, :run_denied)
        [result_for_class, result_for_a_method, result_for_d_method]
      end
      expect(result).to eq([true, true, true])
    end

    it 'can use policy_for and deny for class and a specified method' do
      result = on_server do
        class UserC
        end
        class Resource
          def run_denied
            raise "it was run though it shouldnt have"
          end
          def run_allowed
            true
          end
        end
        class TestClassPolicyC < LucidPolicy::Base
          policy_for UserC
          allow Resource, :run_allowed
          deny Resource, :run_denied
        end
        result_for_class = UserC.new.authorized?(Resource)
        result_for_a_method = UserC.new.authorized?(Resource, :run_allowed)
        result_for_d_method = UserC.new.authorized?(Resource, :run_denied)
        [result_for_class, result_for_a_method, result_for_d_method]
      end
      expect(result).to eq([false, true, false])
    end

    it 'can use policy_for and deny for class and a specified method and allow for others' do
      result = on_server do
        class UserD
        end
        class Resource
          def run_denied
            raise "it was run though it shouldnt have"
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
        class TestClassPolicyD < LucidPolicy::Base
          policy_for UserD
          deny Resource, :run_denied
          allow others
        end
        result_for_class = UserD.new.authorized?(OtherResource)
        result_for_a_method = UserD.new.authorized?(OtherResource, :run_allowed)
        result_for_d_method = UserD.new.authorized?(Resource, :run_denied)
        [result_for_class, result_for_a_method, result_for_d_method]
      end
      expect(result).to eq([true, true, false])
    end

    it 'can use several policies' do
      result = on_server do
        class UserE
        end
        class Resource
          def run_denied
            raise "it was run though it shouldnt have"
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
        class TestClassPolicyE1 < LucidPolicy::Base
          policy_for UserE
          deny Resource, :run_denied
          allow others
        end
        class TestClassPolicyE2 < LucidPolicy::Base
          policy_for UserE
          deny Resource, :run_allowed
          allow others
        end
        result_for_class = UserE.new.authorized?(OtherResource)
        result_for_a_method = UserE.new.authorized?(Resource, :run_allowed)
        result_for_d_method = UserE.new.authorized?(Resource, :run_denied)
        [result_for_class, result_for_a_method, result_for_d_method]
      end
      expect(result).to eq([true, false, false])
    end

    it 'can use a policy with a condition that denies' do
      result = on_server do
        class UserF
          def validated?
            false
          end
        end
        class Resource
          def run_denied
            raise "it was run though it shouldnt have"
          end
          def run_allowed
            true
          end
        end
        class TestClassPolicyF < LucidPolicy::Base
          policy_for UserF
          allow Resource
          with_condition do |user, resource_class, resource_method|
            user.validated?
          end
        end
        result_for_class = UserF.new.authorized?(Resource)
        result_for_a_method = UserF.new.authorized?(Resource, :run_allowed)
        result_for_d_method = UserF.new.authorized?(Resource, :run_denied)
        [result_for_class, result_for_a_method, result_for_d_method]
      end
      expect(result).to eq([false, false, false])
    end

    it 'can use a policy with a condition that allows' do
      result = on_server do
        class UserG
          def validated?
            true
          end
        end
        class Resource
          def run_denied
            raise "it was run though it shouldnt have"
          end
          def run_allowed
            true
          end
        end
        class TestClassPolicyG < LucidPolicy::Base
          policy_for UserG
          allow Resource
          with_condition do |user, resource_class, resource_method|
            user.validated?
          end
        end
        result_for_class = UserG.new.authorized?(Resource)
        result_for_a_method = UserG.new.authorized?(Resource, :run_allowed)
        result_for_d_method = UserG.new.authorized?(Resource, :run_denied)
        [result_for_class, result_for_a_method, result_for_d_method]
      end
      expect(result).to eq([true, true, true])
    end
    it 'can use a policy and refine a rule and allows' do
      result = on_server do
        class UserH
          def validated?
            true
          end
        end
        class Resource
          def run_denied
            raise "it was run though it shouldnt have"
          end
          def run_allowed
            true
          end
        end
        class TestClassPolicyH < LucidPolicy::Base
          policy_for UserH
          deny Resource
          refine Resource, :run_allowed do |user, target_class, target_method|
            allow if user.validated?
            deny
          end
        end
        result_for_class = UserH.new.authorized?(Resource)
        result_for_a_method = UserH.new.authorized?(Resource, :run_allowed)
        result_for_d_method = UserH.new.authorized?(Resource, :run_denied)
        [result_for_class, result_for_a_method, result_for_d_method]
      end
      expect(result).to eq([false, true, false])
    end

    it 'can use a policy and refine a rule and denies' do
      result = on_server do
        class UserI
          def validated?
            false
          end
        end
        class Resource
          def run_denied
            raise "it was run though it shouldnt have"
          end
          def run_allowed
            true
          end
        end
        class TestClassPolicyI < LucidPolicy::Base
          policy_for UserI
          allow Resource
          refine Resource, :run_denied do |user, target_class, target_method|
            allow if user.validated?
            deny
          end
        end
        result_for_class = UserI.new.authorized?(Resource)
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
        end
        class Resource
          def run_denied
            raise "it was run though it shouldnt have"
          end
          def run_allowed
            true
          end
        end
        class TestClassPolicyB < LucidPolicy::Base
          policy_for UserB
          allow Resource
        end
        result_for_class = UserB.new.authorized?(Resource)
        result_for_a_method = UserB.new.authorized?(Resource, :run_allowed)
        result_for_d_method = UserB.new.authorized?(Resource, :run_denied)
        [result_for_class, result_for_a_method, result_for_d_method]
      end
      expect(result).to eq([true, true, true])
    end

    it 'can use policy_for and deny for class and a specified method' do
      result = @doc.evaluate_ruby do
        class UserC
        end
        class Resource
          def run_denied
            raise "it was run though it shouldnt have"
          end
          def run_allowed
            true
          end
        end
        class TestClassPolicyC < LucidPolicy::Base
          policy_for UserC
          allow Resource, :run_allowed
          deny Resource, :run_denied
        end
        result_for_class = UserC.new.authorized?(Resource)
        result_for_a_method = UserC.new.authorized?(Resource, :run_allowed)
        result_for_d_method = UserC.new.authorized?(Resource, :run_denied)
        [result_for_class, result_for_a_method, result_for_d_method]
      end
      expect(result).to eq([false, true, false])
    end

    it 'can use policy_for and deny for class and a specified method and allow for others' do
      result = @doc.evaluate_ruby do
        class UserD
        end
        class Resource
          def run_denied
            raise "it was run though it shouldnt have"
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
        class TestClassPolicyD < LucidPolicy::Base
          policy_for UserD
          deny Resource, :run_denied
          allow others
        end
        result_for_class = UserD.new.authorized?(OtherResource)
        result_for_a_method = UserD.new.authorized?(OtherResource, :run_allowed)
        result_for_d_method = UserD.new.authorized?(Resource, :run_denied)
        [result_for_class, result_for_a_method, result_for_d_method]
      end
      expect(result).to eq([true, true, false])
    end

    it 'can use several policies' do
      result = @doc.evaluate_ruby do
        class UserE
        end
        class Resource
          def run_denied
            raise "it was run though it shouldnt have"
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
        class TestClassPolicyE1 < LucidPolicy::Base
          policy_for UserE
          deny Resource, :run_denied
          allow others
        end
        class TestClassPolicyE2 < LucidPolicy::Base
          policy_for UserE
          deny Resource, :run_allowed
          allow others
        end
        result_for_class = UserE.new.authorized?(OtherResource)
        result_for_a_method = UserE.new.authorized?(Resource, :run_allowed)
        result_for_d_method = UserE.new.authorized?(Resource, :run_denied)
        [result_for_class, result_for_a_method, result_for_d_method]
      end
      expect(result).to eq([true, false, false])
    end

    it 'can use a policy with a condition that denies' do
      result = @doc.evaluate_ruby do
        class UserF
          def validated?
            false
          end
        end
        class Resource
          def run_denied
            raise "it was run though it shouldnt have"
          end
          def run_allowed
            true
          end
        end
        class TestClassPolicyF < LucidPolicy::Base
          policy_for UserF
          allow Resource
          with_condition do |user, resource_class, resource_method|
            user.validated?
          end
        end
        result_for_class = UserF.new.authorized?(Resource)
        result_for_a_method = UserF.new.authorized?(Resource, :run_allowed)
        result_for_d_method = UserF.new.authorized?(Resource, :run_denied)
        [result_for_class, result_for_a_method, result_for_d_method]
      end
      expect(result).to eq([false, false, false])
    end

    it 'can use a policy with a condition that allows' do
      result = @doc.evaluate_ruby do
        class UserG
          def validated?
            true
          end
        end
        class Resource
          def run_denied
            raise "it was run though it shouldnt have"
          end
          def run_allowed
            true
          end
        end
        class TestClassPolicyG < LucidPolicy::Base
          policy_for UserG
          allow Resource
          with_condition do |user, resource_class, resource_method|
            user.validated?
          end
        end
        result_for_class = UserG.new.authorized?(Resource)
        result_for_a_method = UserG.new.authorized?(Resource, :run_allowed)
        result_for_d_method = UserG.new.authorized?(Resource, :run_denied)
        [result_for_class, result_for_a_method, result_for_d_method]
      end
      expect(result).to eq([true, true, true])
    end

    it 'can use a policy and refine a rule and allows' do
      result = @doc.evaluate_ruby do
        class UserH
          def validated?
            true
          end
        end
        class Resource
          def run_denied
            raise "it was run though it shouldnt have"
          end
          def run_allowed
            true
          end
        end
        class TestClassPolicyH < LucidPolicy::Base
          policy_for UserH
          deny Resource
          refine Resource, :run_allowed do |user, target_class, target_method|
            allow if user.validated?
            deny
          end
        end
        result_for_class = UserH.new.authorized?(Resource)
        result_for_a_method = UserH.new.authorized?(Resource, :run_allowed)
        result_for_d_method = UserH.new.authorized?(Resource, :run_denied)
        [result_for_class, result_for_a_method, result_for_d_method]
      end
      expect(result).to eq([false, true, false])
    end

    it 'can use a policy and refine a rule and denies' do
      result = @doc.evaluate_ruby do
        class UserI
          def validated?
            false
          end
        end
        class Resource
          def run_denied
            raise "it was run though it shouldnt have"
          end
          def run_allowed
            true
          end
        end
        class TestClassPolicyI < LucidPolicy::Base
          policy_for UserI
          allow Resource
          refine Resource, :run_denied do |user, target_class, target_method|
            allow if user.validated?
            deny
          end
        end
        result_for_class = UserI.new.authorized?(Resource)
        result_for_a_method = UserI.new.authorized?(Resource, :run_allowed)
        result_for_d_method = UserI.new.authorized?(Resource, :run_denied)
        [result_for_class, result_for_a_method, result_for_d_method]
      end
      expect(result).to eq([true, true, false])
    end
  end

  #context 'Server Side Rendering' do
    # before do
    #   @doc = visit('/ssr')
    # end
    #
    # it 'renders on the server' do
    #   expect(@doc.html).to include('Rendered!')
    # end
    #
    # it 'translates' do
    #   expect(@doc.html).to include('einfach')
    # end
  #end
end
