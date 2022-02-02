# frozen_string_literal: true

module LucidOperation
  module Mixin
    def self.included(base)
      base.extend(LucidPropDeclaration::Mixin)

      if RUBY_ENGINE == 'opal'
        base.instance_exec do
          def procedure(gherkin_text)
          end

          def steps
          end
          alias :gherkin :steps
          alias :ensure_steps :steps
          alias :failure_steps :steps
          alias :Given :steps
          alias :And :steps
          alias :Then :steps
          alias :When :steps
          alias :Ensure :steps
          alias :Failed :steps
          alias :If_failing :steps
          alias :When_failing :steps
          alias :If_this_failed :steps
          alias :If_that_failed :steps

          def First(regular_expression, &block)
            Isomorfeus.raise_error(message: "#{self}: First already defined, can only be defined once!") if @first_defined
            @first_defined = true
          end

          def Finally(regular_expression, &block)
            Isomorfeus.raise_error(message: "#{self}: Finally already defined, can only be defined once!") if @finally_defined
            @finally_defined = true
          end

          def promise_run(**props_hash)
            props = validated_props(props_hash)
            Isomorfeus::Transport.promise_send_path('Isomorfeus::Operation::Handler::OperationHandler', self.name, props).then do |agent|
              agent.process do |agnt|
                agnt.response[:result]
              end
              if agent.result.key?(:rejected)
                if agent.result.key?(:error)
                  e = agent.result[:error]
                  exception_class_name = e[:class_name]
                  exception_class = exception_class_name.constantize
                  exception = exception_class.new(e[:message])
                  exception.set_backtrace(e[:backtrace])
                  raise exception
                else
                  raise agent.result[:rejected]
                end
              else
                agent.result[:resolved]
              end
            end
          end
        end
      else
        Isomorfeus.add_valid_operation_class(base) unless base == LucidOperation::Base
        base.extend(LucidOperation::Steps)
        base.include(LucidOperation::PromiseRun)

        base.instance_exec do
          def promise_run(**props_hash)
            self.new(**props_hash).promise_run
          end
        end

        attr_reader :props
        attr_accessor :step_result

        def initialize(**props_hash)
          props_hash = self.class.validated_props(props_hash)
          @props = LucidProps.new(props_hash)
        end

        def current_user
          Isomorfeus.current_user
        end

        def pub_sub_client
          Isomorfeus.pub_sub_client
        end
      end
    end
  end
end
