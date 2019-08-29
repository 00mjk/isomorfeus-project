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
            raise "#{self}: First already defined, can only be defined once!" if @first_defined
            @first_defined = true
          end

          def Finally(regular_expression, &block)
            raise "#{self}: Finally already defined, can only be defined once!" if @finally_defined
            @finally_defined = true
          end

          def promise_run(props_hash)
            validate_props(props_hash)
            props_json = Isomorfeus::Data::Props.new(props_hash).to_json
            Isomorfeus::Transport.promise_send_path('Isomorfeus::Operation::Handler::OperationHandler', self.name, props_json).then do |agent|
              if agent.processed
                agent.result
              else
                agent.processed = true
                if agent.response.key?(:error)
                  `console.error(#{agent.response[:error].to_n})`
                  raise agent.response[:error]
                end
                agent.result = agent.response[:result]
              end
            end
          end
        end
      else
        Isomorfeus.add_valid_operation_class(base) unless base == LucidOperation::Base
        base.extend(Isomorfeus::Operation::Mixin)
        base.include(Isomorfeus::Operation::PromiseRun)

        unless base == LucidOperation::Base
          base.prop :pub_sub_client, default: nil
          base.prop :current_user, default: nil
        end

        base.instance_exec do
          def promise_run(props_hash)
            validate_props(props_hash)
            self.new(props_hash).promise_run
          end
        end

        attr_accessor :props
        attr_accessor :step_result
      end
    end
  end
end
