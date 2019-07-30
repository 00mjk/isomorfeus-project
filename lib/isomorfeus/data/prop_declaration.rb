module Isomorfeus
  module Data
    module PropDeclaration
      # props, very similar to Components:
      #   prop :text, class: String # a required prop of class String, class must match exactly
      #   prop :other, is_a: Enumerable # a required prop, which can be a Array for example, but at least must be a Enumerable
      #   prop :cool, default: 'yet some more text' # a optional prop with a default value
      #   prop :even_cooler, class: String, required: false
      def prop(prop_name, options_hash = {})
        declared_props[prop_name.to_sym] = options_hash
      end

      def declared_props
        @declared_props ||= {}
      end

      def validate_props(props_hash)
        p = declared_props

        props = Isomorfeus::Data::Props.new(props_hash)

        raise "#{self}: Wrong or to many props given!" if (props.keys - p.keys).size > 0

        # validation
        p.each_key do |key|
          # determine if prop is required
          required = if p[key].key?(:required)
                       p[key][:required]
                     elsif p[key].key?(:default)
                       false
                     else
                       true
                     end

          # assign value
          value = if props.key?(key)
                    props[key]
                  elsif p[key].key?(:default)
                    props_hash[key] = p[key][:default].dup
                  else
                    raise "#{self}: Required prop not given: #{key}!" if required
                    nil
                  end

          # check if passed value is of correct type
          if props_hash.key?(key)
            if p[key].key?(:class) && value.class != (p[key][:class])
              raise "#{self}: #{key} value is not of class #{p[key][:class]} but instead a #{value.class}!"
            end
            if p[key].key?(:is_a) && !value.is_a?(p[key][:is_a])
              raise "#{self}: #{key} value is not a #{p[key][:is_a]}!"
            end
          end
        end
      end
    end
  end
end
