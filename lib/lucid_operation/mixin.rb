module LucidOperation
  module Mixin
    def self.included(base)
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
        end
      else
        Isomorfeus.add_valid_operation_class(base) unless base == LucidOperation::Base
        base.extend(Isomorfeus::Operation::Mixin)
      end

      base.extend(Isomorfeus::Data::PropDeclaration)

      if RUBY_ENGINE == 'opal'
        base.instance_exec do
          def promise_run(props_hash)
            validate_props(props_hash)
            props_json = Isomorfeus::Data::Props.new(props_hash).to_json
            Isomorfeus::Transport.promise_send_path('Isomorfeus::Operation::Handler::OperationHandler', self.name, props_json)
          end
        end
      else
        base.instance_exec do
          def promise_run(props_hash)
            validate_props(props_hash)
            self.new(props_hash).promise_run
          end
        end

        attr_accessor :props
        attr_accessor :step_result

        def initialize(validated_props_hash)
          @props = Isomorfeus::Data::Props.new(validated_props_hash)
        end

        def promise_run
          promise = Promise.new
          operation = self

          # steps
          self.class.gherkin[:steps].each do |gherkin_step|
            matched = false
            self.class.steps.each do |step|
              # step[0] -> regular_expression
              # step[1] -> block
              match_data = gherkin_step.match(step[0])
              if match_data
                matched = true
                promise.then do |result|
                  operation.step_result = result
                  operation.instance_exec(step[1].call(*match_data))
                end
              end
            end
            raise "No match found for step #{gherkin_step}!" unless matched
          end

          # fail track
          self.class.gherkin[:failure].each do |gherkin_step|
            matched = false
            self.class.failure_steps.each do |step|
              # step[0] -> regular_expression
              # step[1] -> block
              match_data = gherkin_step.match(step[0])
              if match_data
                matched = true
                promise.fail do |result|
                  operation.step_result = result
                  operation.instance_exec(step[1].call(*match_data))
                end
              end
            end
            raise "No match found for failure step #{gherkin_step}!" unless matched
          end

          # ensure
          self.class.gherkin[:ensure].each do |gherkin_step|
            matched = false
            self.class.ensure_steps.each do |step|
              # step[0] -> regular_expression
              # step[1] -> block
              match_data = gherkin_step.match(step[0])
              if match_data
                matched = true

                promise.then do |result|
                  operation.step_result = result
                  operation.instance_exec(step[1].call(*match_data))
                end.fail do |result|
                  operation.step_result = result
                  operation.instance_exec(step[1].call(*match_data))
                end
              end
            end
            raise "No match found for ensure step #{gherkin_step}!" unless matched
          end

          promise.resolve(true)
        end
      end
    end
  end
end
