module LucidLocalOperation
  module Mixin
    def self.included(base)
      if RUBY_ENGINE != 'opal'
        Isomorfeus.add_valid_operation_class(base) unless base == LucidLocalOperation::Base

        def pub_sub_client
          Isomorfeus.pub_sub_client
        end
      end

      base.extend(LucidPropDeclaration::Mixin)
      base.extend(LucidOperation::Steps)
      base.include(LucidOperation::PromiseRun)

      base.instance_exec do
        def promise_run(props_hash = nil, props: nil)
          props_hash = props_hash || props
          validate_props(props_hash)
          self.new(props_hash).promise_run
        end
      end
    end

    attr_accessor :props
    attr_accessor :step_result

    def current_user
      Isomorfeus.current_user
    end
  end
end
