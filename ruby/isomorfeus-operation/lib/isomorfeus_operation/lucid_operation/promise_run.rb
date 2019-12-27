module LucidOperation
  module PromiseRun
    def initialize(validated_props_hash)
      @props = Isomorfeus::Transport::PropsProxy.new(validated_props_hash)
    end

    def promise_run
      promise = Promise.new
      original_promise = promise
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
            promise = promise.then do |result|
              operation.step_result = result
              operation.instance_exec(*match_data, &step[1])
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
            promise = promise.fail do |result|
              operation.step_result = result
              operation.instance_exec(*match_data, &step[1])
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

            promise = promise.then do |result|
              operation.step_result = result
              operation.instance_exec(*match_data, &step[1])
            end.fail do |result|
              operation.step_result = result
              operation.instance_exec(*match_data, &step[1])
            end
          end
        end
        raise "No match found for ensure step #{gherkin_step}!" unless matched
      end

      original_promise.resolve
      promise
    end
  end
end
