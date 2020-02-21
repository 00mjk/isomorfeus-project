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

    it 'can use policy and by default deny authorization' do
      result = on_server do
        class ::UserA
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
        class ::UserAPolicy < LucidPolicy::Base
        end
        result_for_class  = UserA.new.authorized?(Resource)
        result_for_method = UserA.new.authorized?(Resource, :run_denied)
        [result_for_class, result_for_method]
      end
      expect(result).to eq([false, false])
    end

    it 'can use policy and allow for class and any method' do
      result = on_server do
        class ::UserB
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
        result_for_class    = UserB.new.authorized!(Resource)
        result_for_a_method = UserB.new.authorized!(Resource, :run_allowed)
        result_for_d_method = UserB.new.authorized!(Resource, :run_denied)
        [result_for_class, result_for_a_method, result_for_d_method]
      end
      expect(result).to eq([true, true, true])
    end

    it 'can use policy and deny for class and a specified method' do
      result = on_server do
        class ::UserC
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

    it 'can use policy and deny for class and a specified method and allow for others' do
      result = on_server do
        class ::UserD
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
        class ::UserF
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
        class ::UserFPolicy < LucidPolicy::Base
          allow Resource, unless: proc { |user| user.validated? }
        end
        result_for_class    = UserF.new.authorized?(Resource)
        result_for_a_method = UserF.new.authorized?(Resource, :run_allowed)
        result_for_d_method = UserF.new.authorized?(Resource, :run_denied)
        [result_for_class, result_for_a_method, result_for_d_method]
      end
      expect(result).to eq([false, false, false])
    end

    it 'can use a policy with a condition that allows as proc' do
      result = on_server do
        class ::UserG
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
          allow Resource, if: proc { |user| user.validated? }
        end
        result_for_class    = UserG.new.authorized?(Resource)
        result_for_a_method = UserG.new.authorized?(Resource, :run_allowed)
        result_for_d_method = UserG.new.authorized?(Resource, :run_denied)
        [result_for_class, result_for_a_method, result_for_d_method]
      end
      expect(result).to eq([true, true, true])
    end

    it 'can use a policy with a condition that allows as symbol' do
      result = on_server do
        class ::UserG
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
          allow Resource, if: :validated?
        end
        result_for_class    = UserG.new.authorized?(Resource)
        result_for_a_method = UserG.new.authorized?(Resource, :run_allowed)
        result_for_d_method = UserG.new.authorized?(Resource, :run_denied)
        [result_for_class, result_for_a_method, result_for_d_method]
      end
      expect(result).to eq([true, true, true])
    end

    it 'can use a policy and define a custom rule that allows' do
      result = on_server do
        class ::UserH
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
          rule Resource, :run_allowed do |user, target_class, target_method|
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

    it 'can use a policy and define a custom rule that denies' do
      result = on_server do
        class ::UserI
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
        class ::UserIPolicy < LucidPolicy::Base
          rule Resource, :run_allowed do |user, target_class, target_method|
            allow unless user.validated?
            deny
          end
        end
        result_for_class    = UserI.new.authorized?(Resource)
        result_for_a_method = UserI.new.authorized?(Resource, :run_allowed)
        result_for_d_method = UserI.new.authorized?(Resource, :run_denied)
        [result_for_class, result_for_a_method, result_for_d_method]
      end
      expect(result).to eq([false, false, false])
    end

    it 'can use a policy and refine a rule with a custom rule that denies' do
      result = on_server do
        class ::UserJ
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
        class ::UserJPolicy < LucidPolicy::Base
          allow Resource
          rule Resource, :run_denied do |user, target_class, target_method|
            allow unless user.validated?
            deny
          end
        end
        result_for_class    = UserJ.new.authorized?(Resource)
        result_for_a_method = UserJ.new.authorized?(Resource, :run_allowed)
        result_for_d_method = UserJ.new.authorized?(Resource, :run_denied)
        [result_for_class, result_for_a_method, result_for_d_method]
      end
      expect(result).to eq([true, true, false])
    end

    it 'can combine Policies that allow' do
      result = on_server do
        class ::UserK
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
        class CombiAPolicy < LucidPolicy::Base
          allow Resource
        end
        class ::UserKPolicy < LucidPolicy::Base
          combine_with CombiAPolicy
          deny others
        end
        result_for_class    = UserK.new.authorized?(Resource)
        result_for_a_method = UserK.new.authorized?(Resource, :run_allowed)
        result_for_d_method = UserK.new.authorized?(Resource, :run_denied)
        [result_for_class, result_for_a_method, result_for_d_method]
      end
      expect(result).to eq([true, true, true])
    end

    it 'can record the winning rule' do
      result = on_server do
        class ::UserL
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
        class CombiAPolicy < LucidPolicy::Base
          allow Resource
        end
        class ::UserLPolicy < LucidPolicy::Base
          combine_with CombiAPolicy
          deny others
        end
        user = UserL.new
        user.record_authorization_reason
        user.authorized?(Resource)
        result_for_class = user.authorization_reason
        user.authorized?(Resource, :load)
        result_for_a_method = user.authorization_reason
        user.authorized?('Test', :load)
        result_for_d_method = user.authorization_reason
        user.stop_to_record_authorization_reason
        user.authorized?('Test', :load)
        result_for_c_method = user.authorization_reason
        [result_for_class, result_for_a_method, result_for_d_method, result_for_c_method]
      end
      expect(result).to eq([{ combined: { class_name: "Resource",
                                          others: :deny,
                                          policy_class: "CombiAPolicy" },
                              policy_class: "UserLPolicy" },
                            { combined: { class_name: "Resource",
                                          others: :deny,
                                          policy_class: "CombiAPolicy" },
                              policy_class: "UserLPolicy" },
                            { combined: { class_name: "Test",
                                          others: :deny,
                                          policy_class: "CombiAPolicy" },
                              policy_class: "UserLPolicy" },
                            nil])
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

    it 'can use policy and by default deny authorization' do
      result = @doc.evaluate_ruby do
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

    it 'can use policy and allow for class and any method' do
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

    it 'can use policy and deny for class and a specified method' do
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

    it 'can use policy and deny for class and a specified method and allow for others' do
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
        class UserFPolicy < LucidPolicy::Base
          allow Resource, unless: proc { |user| user.validated? }
        end
        result_for_class    = UserF.new.authorized?(Resource)
        result_for_a_method = UserF.new.authorized?(Resource, :run_allowed)
        result_for_d_method = UserF.new.authorized?(Resource, :run_denied)
        [result_for_class, result_for_a_method, result_for_d_method]
      end
      expect(result).to eq([false, false, false])
    end

    it 'can use a policy with a condition that allows as proc' do
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
          allow Resource, if: proc { |user| user.validated? }
        end
        result_for_class    = UserG.new.authorized?(Resource)
        result_for_a_method = UserG.new.authorized?(Resource, :run_allowed)
        result_for_d_method = UserG.new.authorized?(Resource, :run_denied)
        [result_for_class, result_for_a_method, result_for_d_method]
      end
      expect(result).to eq([true, true, true])
    end

    it 'can use a policy with a condition that allows as symbol' do
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
          allow Resource, if: :validated?
        end
        result_for_class    = UserG.new.authorized?(Resource)
        result_for_a_method = UserG.new.authorized?(Resource, :run_allowed)
        result_for_d_method = UserG.new.authorized?(Resource, :run_denied)
        [result_for_class, result_for_a_method, result_for_d_method]
      end
      expect(result).to eq([true, true, true])
    end

    it 'can use a policy and define a custom rule tha allows' do
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
          rule Resource, :run_allowed do |user, target_class, target_method|
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

    it 'can use a policy and define a custom rule that denies' do
      result = @doc.evaluate_ruby do
        class UserI
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
        class UserIPolicy < LucidPolicy::Base
          rule Resource, :run_allowed do |user, target_class, target_method|
            allow unless user.validated?
            deny
          end
        end
        result_for_class    = UserI.new.authorized?(Resource)
        result_for_a_method = UserI.new.authorized?(Resource, :run_allowed)
        result_for_d_method = UserI.new.authorized?(Resource, :run_denied)
        [result_for_class, result_for_a_method, result_for_d_method]
      end
      expect(result).to eq([false, false, false])
    end

    it 'can use a policy and refine a rule with a custom rule that denies' do
      result = @doc.evaluate_ruby do
        class UserJ
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
        class UserJPolicy < LucidPolicy::Base
          allow Resource
          rule Resource, :run_denied do |user, target_class, target_method|
            allow unless user.validated?
            deny
          end
        end
        result_for_class    = UserJ.new.authorized?(Resource)
        result_for_a_method = UserJ.new.authorized?(Resource, :run_allowed)
        result_for_d_method = UserJ.new.authorized?(Resource, :run_denied)
        [result_for_class, result_for_a_method, result_for_d_method]
      end
      expect(result).to eq([true, true, false])
    end

    it 'can combine Policies that allow' do
      result = @doc.evaluate_ruby do
        class UserK
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
        class CombiAPolicy < LucidPolicy::Base
          allow Resource
        end
        class UserKPolicy < LucidPolicy::Base
          combine_with CombiAPolicy
          deny others
        end
        result_for_class    = UserK.new.authorized!(Resource)
        result_for_a_method = UserK.new.authorized!(Resource, :run_allowed)
        result_for_d_method = UserK.new.authorized!(Resource, :run_denied)
        [result_for_class, result_for_a_method, result_for_d_method]
      end
      expect(result).to eq([true, true, true])
    end

    it 'can record the winning rule' do
      result = @doc.evaluate_ruby do
        class UserL
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
        class CombiAPolicy < LucidPolicy::Base
          allow Resource
        end
        class UserLPolicy < LucidPolicy::Base
          combine_with CombiAPolicy
          deny others
        end
        user = UserL.new
        user.record_authorization_reason
        user.authorized?(Resource)
        result_for_class = user.authorization_reason.to_n
        user.authorized?(Resource, :load)
        result_for_a_method = user.authorization_reason.to_n
        user.authorized?('Test', :load)
        result_for_d_method = user.authorization_reason.to_n
        user.stop_to_record_authorization_reason
        user.authorized?('Test', :load)
        result_for_c_method = user.authorization_reason.to_n
        [result_for_class, result_for_a_method, result_for_d_method, result_for_c_method]
      end
      expect(result).to eq([{ 'combined' =>{ 'class_name' => "Resource",
                                             'others' => 'deny',
                                             'policy_class' => "CombiAPolicy" },
                              'policy_class' => "UserLPolicy" },
                            { 'combined' => { 'class_name' => "Resource",
                                              'others' => 'deny',
                                              'policy_class' => "CombiAPolicy" },
                              'policy_class' => "UserLPolicy" },
                            { 'combined' => { 'class_name' => "Test",
                                              'others' => 'deny',
                                              'policy_class' => "CombiAPolicy" },
                              'policy_class' => "UserLPolicy" },
                            nil])
    end
  end
end
