module LucidPolicy
  module Mixin
    def self.included(base)
      base.instance_exec do
        if RUBY_ENGINE != 'opal'
          Isomorfeus.add_valid_policy_class(base) unless base == LucidPolicy::Base
        end

        def authorization_rules
          @authorization_rules ||= { rules: {}.dup, policies: {}.dup, others: :deny }.dup
        end

        def all
          :others
        end

        def allow(*classes_and_methods_and_options)
          _allow_or_deny(:allow, *classes_and_methods_and_options)
        end

        def deny(*classes_and_methods_and_options)
          _allow_or_deny(:deny, *classes_and_methods_and_options)
        end

        def others
          :others
        end

        def rule(*classes_and_methods, &block)
          _allow_or_deny(:rule, *classes_and_methods, &block)
        end

        def combine_with(policy_class, **options)
          authorization_rules[:policies] = { policy_class => options }
        end

        private

        def _allow_or_deny(thing, *classes_methods_options, &block)
          rules = authorization_rules

          if %i[allow deny].include?(thing) && classes_methods_options.first == :others
            rules[:others] = thing
            return
          end

          target_classes = []
          target_methods = []
          target_options = {}

          classes_methods_options.each do |class_method_option|
            if class_method_option.class == Hash
              target_options = class_method_option
            else
              class_or_method_s = class_method_option.to_s
              if class_method_option.class == Symbol && class_or_method_s[0].downcase == class_or_method_s[0]
                target_methods << class_method_option
              else
                class_method_option = class_or_method_s unless class_method_option.class == String
                target_classes << class_method_option
              end
            end
          end

          thing_or_block = block_given? ? block : thing

          target_classes.each do |target_class|
            target_class = target_class.split('>::').last if target_class.start_with?('#<')
            rules[:rules][target_class] = {} unless rules[:rules].key?(target_class)

            if target_methods.empty?
              rules[:rules][target_class][:rule] = thing_or_block
              rules[:rules][target_class][:options] = target_options unless target_options.empty?
            else
              rules[:rules][target_class][:rule] = :deny unless rules[:rules][target_class].key?(:rule)
              rules[:rules][target_class][:methods] = {} unless rules[:rules][target_class].key?(:methods)
              target_methods.each do |target_method|
                rules[:rules][target_class][:methods][target_method] = { rule: thing_or_block }
                rules[:rules][target_class][:methods][target_method][:options] = target_options unless target_options.empty?
              end
            end
          end
        end
      end

      attr_reader :reason

      def initialize(object, record_reason = nil)
        @object = object
        @reason = nil
        @record_reason = record_reason
        if @record_reason
          @class_name = self.class.name
          @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
        end
      end

      def authorized?(target_class, target_method = nil, props = nil)
        Isomorfeus.raise_error(error_class: LucidPolicy::Exception, message: "#{self}: At least the class or class name must be given!") unless target_class

        target_class = target_class.to_s unless target_class.class == String
        target_class = target_class.split('>::').last if target_class.start_with?('#<')

        rules  =  self.class.authorization_rules

        result =  if rules[:rules].key?(target_class)
                    if target_method && rules[:rules][target_class].key?(:methods) && rules[:rules][target_class][:methods].key?(target_method)
                      options = rules[:rules][target_class][:methods][target_method][:options]
                      rule = rules[:rules][target_class][:methods][target_method][:rule]
                      @reason = { policy_class: @class_name, class_name: target_class, method: target_method, rule: rule } if @record_reason
                    else
                      options = rules[:rules][target_class][:options]
                      rule = rules[:rules][target_class][:rule]
                      @reason = { policy_class: @class_name, class_name: target_class, rule: rule } if @record_reason
                    end

                    if rule.class == Symbol || rule.class == String
                      if options
                        condition, method_result = __get_condition_and_result(options)
                        if @record_reason
                          @reason[:condition] = condition
                          @reason[:condition_result] = method_result
                        end
                        rule if (condition == :if && method_result == true) || (condition == :if_not && method_result == false)
                      else
                        rule
                      end
                    else
                      props = LucidProps.new(props) unless props.class == LucidProps
                      policy_helper = LucidPolicy::Helper.new
                      policy_helper.instance_exec(@object, target_class, target_method, props, &rule)
                      r = policy_helper.result
                      @reason[:rule_result] = r if @record_reason
                      r
                    end
                  else
                    r = rules[:others]
                    @reason = { policy_class: @class_name, class_name: target_class, others: r } if @record_reason
                    r
                  end

        return true if result == :allow

        rules[:policies].each do |policy_class, options|
          combined_policy_result = nil
          if options.empty?
            policy_instance = policy_class.new(@object, @record_reason)
            combined_policy_result = policy_instance.authorized?(target_class, target_method, props)
            @reason = @reason = { policy_class: @class_name, combined: policy_instance.reason } if @record_reason
          else
            condition, method_result = __get_condition_and_result(options)
            if (condition == :if && method_result == true) || (condition == :if_not && method_result == false)
              policy_instance = policy_class.new(@object, @record_reason)
              combined_policy_result = policy_instance.authorized?(target_class, target_method, props)
              @reason = { policy_class: @class_name, combined: policy_instance.reason, condition: condition, condition_result: method_result } if @record_reason
            end
          end
          return true if combined_policy_result == true
        end

        result == :allow ? true : false
      end

      def authorized!(target_class, target_method = nil, props = nil)
        result = authorized?(target_class, target_method, props)
        reason_message = reason ? ", reason: #{reason}" : ''
        return true if result
        Isomorfeus.raise_error(error_class: LucidPolicy::Exception, message: "#{@object}: not authorized to call #{target_class}#{}#{target_method} #{props} #{reason_message}!")
      end

      private

      def __get_condition_and_result(options)
        condition = nil
        method_name_or_block = if options.key?(:if)
                                 condition = :if
                                 options[:if]
                               elsif options.key?(:if_not)
                                 condition = :if_not
                                 options[:if_not]
                               elsif options.key?(:unless)
                                 condition = :if_not
                                 options[:unless]
                               end
        method_result = if method_name_or_block && method_name_or_block.class == Symbol
                          @object.__send__(method_name_or_block)
                        else
                          props = LucidProps.new(props) unless props.class == LucidProps
                          method_name_or_block.call(@object, props)
                        end
        [condition, method_result]
      end
    end
  end
end
