module LucidPolicy
  module Mixin
    def self.included(base)
      if RUBY_ENGINE != 'opal'
        Isomorfeus.add_valid_policy_class(base) unless base == LucidPolicy::Base
      end

      # DSL
      # class MySimplePolicy < LucidPolicy::Base
      #
      #   policy_for UserOrRoleClass
      #
      #   allow BlaBlaGraph, :load
      #
      #   deny BlaGraph, SuperOperation
      #
      #   deny others # or: allow others
      #
      #   with_condition do |user_or_role_instance, target_class, target_method, *props|
      #      role.class == AdminRole
      #   end
      #
      #   refine BlaGraph, :load, :count do |user_or_role_instance, target_class, target_method, *props|
      #     allow if role.verified?
      #     deny
      #   end
      # end
      #
      base.instance_exec do
        def policy_for(a_class)
          raise LucidPolicy::Exception, "policy_for #{a_class} can only be used once within #{self}!" if @the_class
          @the_class = a_class
          unless a_class.methods.include?(:authorization_rules)
            a_class.define_singleton_method(:authorization_rules) do
              @authorization_rules ||= { classes: {}, conditions: [], others: nil, policy_classes: [] }
            end
          end
          unless a_class.method_defined?(:authorized?)
            a_class.define_method(:authorized?) do |*class_method_props|
              target_class = class_method_props[0]
              raise "At least the class must be given!" unless target_class
              target_method = class_method_props[1]
              props = class_method_props[2..-1]

              condition_result = true
              self.class.authorization_rules[:conditions].each do |condition|
                condition_result = condition.call(self, target_class, target_method, *props, &condition)
                break unless condition_result == true
              end

              if condition_result
                result = if self.class.authorization_rules[:classes].key?(target_class)
                           if target_method &&
                              self.class.authorization_rules[:classes][target_class].key?(:methods) &&
                              self.class.authorization_rules[:classes][target_class][:methods].key?(target_method)
                             self.class.authorization_rules[:classes][target_class][:methods][target_method]
                           else
                             self.class.authorization_rules[:classes][target_class][:default]
                           end
                         else
                           self.class.authorization_rules[:others]
                         end

                if result.class == Proc
                  policy_helper = Isomorfeus::Policy::Helper.new
                  policy_helper.instance_exec(self, target_class, target_method, *props, &result)
                  result = policy_helper.result
                end

                result == :allow ? true : false
              else
                false
              end
            end
          end
          unless a_class.method_defined?(:authorized!)
            a_class.define_method(:authorized!) do |*class_method_props|
              return true if authorized?(*class_method_props)
              raise LucidPolicy::Exception, "#{self} not authorized to call #{class_method_props}"
            end
          end
          @the_class.authorization_rules[:policy_classes] << self
        end

        def allow(*classes_and_methods)
          _raise_allow_deny_first if @refine_used
          _allow_or_deny(:allow, *classes_and_methods)
        end

        def deny(*classes_and_methods)
          _raise_allow_deny_first if @refine_used
          _allow_or_deny(:deny, *classes_and_methods)
        end

        def others
          :others
        end

        def refine(*classes_and_methods, &block)
          @refine_used = true
          _allow_or_deny(nil, *classes_and_methods, &block)
        end

        def with_condition(&block)
          _raise_policy_first unless @the_class
          @the_class.authorization_rules[:conditions] << block
        end

        private

        def _raise_policy_first
          raise LucidPolicy::Exception, "'allow' or 'deny' must appear before 'refine'"
        end

        def _raise_policy_first
          raise LucidPolicy::Exception, "policy_for Class must be specified first"
        end

        def _allow_or_deny(allow_or_deny, *classes_and_methods, &block)
          _raise_policy_first unless @the_class

          allow_or_deny_or_block = block_given? ? block : allow_or_deny.to_sym

          target_classes = []
          target_methods = []

          if classes_and_methods.first == :others
            @the_class.authorization_rules[:others] = allow_or_deny_or_block
            return
          end

          classes_and_methods.each do |class_or_method|
            if (class_or_method.class == String || class_or_method.class == Symbol) && class_or_method.to_s[0].downcase == class_or_method.to_s[0]
              target_methods << class_or_method.to_sym
            else
              target_classes << class_or_method
            end
          end

          target_classes.each do |target_class|
            @the_class.authorization_rules[:classes][target_class] = {} unless @the_class.authorization_rules[:classes].key?(target_class)
            if allow_or_deny && target_methods.empty?
              @the_class.authorization_rules[:classes][target_class][:default] = allow_or_deny_or_block
            else
              @the_class.authorization_rules[:classes][target_class][:default] = :deny unless @the_class.authorization_rules[:classes][target_class].key?(:default)
              @the_class.authorization_rules[:classes][target_class][:methods] = {} unless @the_class.authorization_rules[:classes][target_class].key?(:methods)
              target_methods.each do |target_method|
                @the_class.authorization_rules[:classes][target_class][:methods][target_method] = allow_or_deny_or_block
              end
            end
          end
        end
      end
    end
  end
end
