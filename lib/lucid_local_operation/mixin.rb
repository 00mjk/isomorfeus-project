module LucidLocalOperation
  module Mixin
    def self.included(base)
      if RUBY_ENGINE != 'opal'
        Isomorfeus.add_valid_operation_class(base) unless base == LucidLocalOperation::Base
      end

      base.extend(Isomorfeus::Data::PropDeclaration)
      base.extend(Isomorfeus::Operation::Mixin)

      base.instance_exec do
        def promise_run(props_hash)
          validate_props(props_hash)
          self.new(props_hash).promise_run
        end
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
