module Isomorfeus
  module Operation
    module Mixin
      def procedure(gherkin_text)
        feature_line = gherkin_text.include?('Operation: ') ? '' : "Operation: #{base.name}\n"
        scenario_line = feature_line == '' || gherkin_text.include?('Procedure: ') ? '' : "  Procedure: #{base.name} executing"
        @procedure = feature_line + scenario_line + gherkin_text
      end

      def gherkin
        @gherkin ||= Isomorfeus::Operation::Gherkin.parse(@procedure)
      end

      def ensure_steps
        @ensure_steps ||= []
      end

      def failure_steps
        @failure_steps ||= []
      end

      def steps
        @steps ||= []
      end

      def First(regular_expression, &block)
        raise "#{self}: First already defined, can only be defined once!" if @first_defined
        @first_defined = true
        steps << [regular_expression, block]
      end

      def Given(regular_expression, &block)
        steps << [regular_expression, block]
      end
      alias :And :Given
      alias :Then :Given
      alias :When :Given

      def Finally(regular_expression, &block)
        raise "#{self}: Finally already defined, can only be defined once!" if @finally_defined
        @finally_defined = true
        steps << [regular_expression, block]
      end

      def Ensure(regular_expression, &block)
        ensure_steps << [regular_expression, block]
      end

      def Failed(regular_expression, &block)
        failure_steps << [regular_expression, block]
      end
      alias :If_failing :Failed
      alias :When_failing :Failed
      alias :If_this_failed :Failed
      alias :If_that_failed :Failed
    end
  end
end
