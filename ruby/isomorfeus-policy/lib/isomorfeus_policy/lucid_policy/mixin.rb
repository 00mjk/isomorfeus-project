module LucidPolicy
  module Mixin
    def self.included(base)
      base.instance_exec do
        if RUBY_ENGINE != 'opal'
          Isomorfeus.add_valid_policy_class(base) unless base == LucidPolicy::Base
        end

        def authorization_rules
          @authorization_rules ||= { classes: {}, conditions: [], others: :deny }
        end

        def all
          :others
        end

        def allow(*classes_and_methods)
          _raise_allow_deny_first if @refine_used
          @allow_deny_used = true
          _allow_or_deny(:allow, *classes_and_methods)
        end

        def deny(*classes_and_methods)
          _raise_allow_deny_first if @refine_used
          @allow_deny_used = true
          _allow_or_deny(:deny, *classes_and_methods)
        end

        def others
          :others
        end

        def refine(*classes_and_methods, &block)
          _raise_allow_deny_first unless @allow_deny_used
          @refine_used = true
          _allow_or_deny(nil, *classes_and_methods, &block)
        end

        def with_condition(&block)
          authorization_rules[:conditions] << block
        end

        private

        def _raise_allow_deny_first
          Isomorfeus.raise_error(error_class: LucidPolicy::Exception, message: "#{self}: 'allow' or 'deny' must appear before 'refine'")
        end

        def _allow_or_deny(allow_or_deny, *classes_and_methods, &block)
          rules              = authorization_rules
          allow_or_deny_or_block = block_given? ? block : allow_or_deny.to_sym

          target_classes = []
          target_methods = []

          if classes_and_methods.first == :others
            rules[:others] = allow_or_deny_or_block
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
            rules[:classes][target_class] = {} unless rules[:classes].key?(target_class)
            if allow_or_deny && target_methods.empty?
              rules[:classes][target_class][:default] = allow_or_deny_or_block
            else
              rules[:classes][target_class][:default] = :deny unless rules[:classes][target_class].key?(:default)
              rules[:classes][target_class][:methods] = {} unless rules[:classes][target_class].key?(:methods)
              target_methods.each do |target_method|
                rules[:classes][target_class][:methods][target_method] = allow_or_deny_or_block
              end
            end
          end
        end
      end

      def initialize(object)
        @object = object
      end

      def authorized?(target_class, target_method = nil, props = nil)
        Isomorfeus.raise_error(error_class: LucidPolicy::Exception, message: "#{self}: At least the class must be given!") unless target_class
        result = :deny

        rules = self.class.authorization_rules

        props = LucidProps.new(props) unless props.class == LucidProps

        condition_result = true
        rules[:conditions].each do |condition|
          condition_result = condition.call(@object, target_class, target_method, props, &condition)
          break unless condition_result == true
        end

        if condition_result == true
          result = if rules[:classes].key?(target_class)
                     if target_method && rules[:classes][target_class].key?(:methods) &&
                       rules[:classes][target_class][:methods].key?(target_method)
                       rules[:classes][target_class][:methods][target_method]
                     else
                       rules[:classes][target_class][:default]
                     end
                   else
                     rules[:others]
                   end

          if result.class == Proc
            policy_helper = LucidPolicy::Helper.new
            policy_helper.instance_exec(@object, target_class, target_method, props, &result)
            result = policy_helper.result
          end
        end

        result == :allow ? true : false
      end

      def authorized!(target_class, target_method = nil, props = nil)
        return true if authorized?(target_class, target_method, props)
        Isomorfeus.raise_error(error_class: LucidPolicy::Exception, message: "#{@object}: not authorized to call #{target_class}.#{target_method}(#{props})!")
      end
    end
  end
end
