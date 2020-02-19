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
            Isomorfeus.raise_error(message: "#{@c}: #{@p} cast failed") unless @e.class == @o[:class]
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
          Isomorfeus.raise_error(message: "#{@c}: #{@p} class not #{@o[:class]}") unless @e.class == @o[:class]
        elsif @o.key?(:is_a)
          Isomorfeus.raise_error(message: "#{@c}: #{@p} is not a #{@o[:is_a]}") unless @e.is_a?(@o[:is_a])
        elsif @o.key?(:type)
          case @o[:type]
          when :boolean
            Isomorfeus.raise_error(message: "#{@c}: #{@p} is not a boolean") unless @e.class == TrueClass || @e.class == FalseClass
          else
            c_string_sub_types
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
        @o[:validate_block].call(@e) if @o.key?(:validate_block)
      end

      # specific validations
      def c_gt(v)
        Isomorfeus.raise_error(message: "#{@c}: #{@p} not greater than #{v}!") unless @e > v
      end

      def c_lt(v)
        Isomorfeus.raise_error(message: "#{@c}: #{@p} not less than #{v}!") unless @e < v
      end

      def c_keys(v)
        Isomorfeus.raise_error(message: "#{@c}: #{@p} keys dont fit!") unless @e.keys.sort == v.sort
      end

      def c_size(v)
        Isomorfeus.raise_error(message: "#{@c}: #{@p} length/size is not #{v}") unless @e.size == v
      end

      def c_matches(v)
        Isomorfeus.raise_error(message: "#{@c}: #{@p} does not match #{v}") unless v.match?(@e)
      end

      def c_max(v)
        Isomorfeus.raise_error(message: "#{@c}: #{@p} is larger than #{v}") unless @e <= v
      end

      def c_min(v)
        Isomorfeus.raise_error(message: "#{@c}: #{@p} is smaller than #{v}") unless @e >= v
      end

      def c_max_size(v)
        Isomorfeus.raise_error(message: "#{@c}: #{@p} is larger than #{v}") unless @e.size <= v
      end

      def c_min_size(v)
        Isomorfeus.raise_error(message: "#{@c}: #{@p} is smaller than #{v}") unless @e.size >= v
      end

      def c_direction(v)
        Isomorfeus.raise_error(message: "#{@c}: #{@p} is positive") if v == :negative && @e >= 0
        Isomorfeus.raise_error(message: "#{@c}: #{@p} is negative") if v == :positive && @e < 0
      end

      def c_test
        Isomorfeus.raise_error(message: "#{@c}: #{@p} test condition check failed") unless @o[:test].call(@e)
      end

      def c_string_sub_types
        Isomorfeus.raise_error(message: "#{@c}: #{@p} must be a String") unless @e.class == String
        case @o[:type]
        when :email
          Isomorfeus.raise_error(message: "#{@c}: #{@p} is not a valid email address") unless @e.match? /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/
        when :uri
          if RUBY_ENGINE == 'opal'
            %x{
              try {
                new URL(#@e);
              } catch {
                #{Isomorfeus.raise_error(message: "#{@c}: #{@p} is not a valid uri")}
              }
            }
          else
            Isomorfeus.raise_error(message: "#{@c}: #{@p} is not a valid uri") unless @e.match? /\A#{URI.regexp}\z/
          end
        end
      end
    end
  end
end
