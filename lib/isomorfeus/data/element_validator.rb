module Isomorfeus
  module Data
    class ElementValidator
      def initialize(source_class, element, options)
        @c = source_class
        @e = element
        @o = options
      end

      def validate!
        ensured = ensure!
        unless ensured
          cast!
          type!
        end
        run_checks!
        true
      end

      private

      # basic tests

      def cast!
        if @o.key?(:cast)
          begin
            @e = case @o[:class]
                 when Integer then @e.to_i
                 when String then @e.to_s
                 when Float then @e.to_f
                 when Array then @e.to_a
                 when Hash then @e.to_h
                 end
            @e = !!@e if @o[:type] == :boolean
          rescue
            raise "#{@c}: #{@p} cast failed" unless @e.class == @o[:class]
          end
        end
      end

      def ensure!
        if @o.key?(:ensure)
          @e = @o[:ensure] unless @e
          true
        elsif @o.key?(:ensure_block)
          @e = @o[:ensure_block].call(@e)
          true
        else
          false
        end
      end

      def type!
        return if @o[:allow_nil] && @e.nil?
        if @o.key?(:class)
          raise "#{@c}: #{@p} class not #{@o[:class]}" unless @e.class == @o[:class]
        elsif @o.key?(:is_a)
          raise "#{@c}: #{@p} is not a #{@o[:is_a]}" unless @e.is_a?(@o[:is_a])
        elsif @o.key?(:type)
          case @o[:type]
          when :boolean
            raise "#{@c}: #{@p} is not a boolean" unless @e.class == TrueClass || @e.class == FalseClass
          end
        end
      end

      # all other checks

      def run_checks!
        if @o.key?(:validate)
          @o[:validate].each do |m, l|
            send('c_' + m, l)
          end
        end
      end

      # specific validations
      def c_gt(v)
        raise "#{@c}: #{@p} not greater than #{v}!" unless @e > v
      end

      def c_lt(v)
        raise "#{@c}: #{@p} not less than #{v}!" unless @e < v
      end

      def c_keys(v)
        raise "#{@c}: #{@p} keys dont fit!" unless @e.keys.sort == v.sort
      end

      def c_size(v)
        raise "#{@c}: #{@p} length/size is not #{v}" unless @e.size == v
      end

      def c_matches(v)
        raise "#{@c}: #{@p} does not match #{v}" unless v.match?(@e)
      end

      def c_max(v)
        raise "#{@c}: #{@p} is larger than #{v}" unless @e <= v
      end

      def c_min(v)
        raise "#{@c}: #{@p} is smaller than #{v}" unless @e >= v
      end

      def c_max_size(v)
        raise "#{@c}: #{@p} is larger than #{v}" unless @e.size <= v
      end

      def c_min_size(v)
        raise "#{@c}: #{@p} is smaller than #{v}" unless @e.size >= v
      end

      def c_direction(v)
        raise "#{@c}: #{@p} is positive" if v == :negative && @e >= 0
        raise "#{@c}: #{@p} is negative" if v == :positive && @e < 0
      end

      def c_test
        raise "#{@c}: #{@p} test condition check failed" unless @o[:test].call(@e)
      end

      def c_sub_type(v)
        case v
        when :email
          # TODO
        when :url
          # TODO
        end
      end
    end
  end
end
