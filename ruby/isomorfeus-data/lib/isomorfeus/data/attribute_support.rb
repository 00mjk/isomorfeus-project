module Isomorfeus
  module Data
    module AttributeSupport
      def self.included(base)
        base.instance_exec do
          def attribute_conditions
            @attribute_conditions ||= {}
          end

          def valid_attribute?(attr_name, attr_value)
            Isomorfeus::Props::Validator.new(self.name, attr_name, attr_value, attribute_conditions[attr_name]).validate!
          rescue
            false
          end

          def validate
            Isomorfeus::Props::ValidateHashProxy.new
          end
        end

        def _validate_attribute(attr_name, attr_val)
          raise "#{@class_name} No such attribute declared: '#{attr_name}'!" unless self.class.attribute_conditions.key?(attr_name)
          Isomorfeus::Props::Validator.new(@class_name, attr_name, attr_val, self.class.attribute_conditions[attr_name]).validate!
        end

        def exclude_attributes(*attrs)
          @_excluded_attributes = attrs
        end

        def select_attributes(*attrs)
          @_selected_attributes = attrs
        end

        if RUBY_ENGINE == 'opal'
          base.instance_exec do
            def attribute(name, options = {})
              attribute_conditions[name] = options

              define_method(name) do
                v = _get_attribute(name)
                %x{
                  if (v instanceof Object && !(v instanceof Array)) {
                    return Opal.Hash.$new(v);
                  } else { return v; }
                }
              end

              define_method("#{name}=") do |val|
                _validate_attribute(name, val)
                changed!
                @_changed_attributes[name] = val
              end
            end
          end

          def _get_attribute(name)
            return @_changed_attributes[name] if @_changed_attributes.key?(name)
            path = @_store_path + [name]
            result = Redux.fetch_by_path(*path)
            return nil if `result === null`
            result
          end

          def _get_attributes
            raw_attributes = Redux.fetch_by_path(*@_store_path)
            hash = Hash.new(raw_attributes)
            hash.merge!(@_changed_attributes) if @_changed_attributes
            hash
          end

          def _get_selected_attributes
            attributes = _get_attributes.dup
            if @_selected_attributes && !@_selected_attributes.empty?
              attributes.each_key do |attr|
                unless @_selected_attributes.include?(attr) || @_selected_attributes.include?(attr)
                  attributes.delete(attr)
                end
              end
            end
            if @_excluded_attributes && !@_excluded_attributes.empty?
              @_excluded_attributes.each { |attr| attributes.delete(attr) }
            end
            attributes
          end
        else
          base.instance_exec do
            def attribute(name, options = {})
              attribute_conditions[name] = options

              define_method(name) do
                @_raw_attributes[name]
              end

              define_method("#{name}=") do |val|
                _validate_attribute(name, val)
                changed!
                @_raw_attributes[name] = val
              end
            end
          end

          def _get_attributes
            @_raw_attributes
          end

          def _get_selected_attributes
            attributes = _get_attributes.transform_keys(&:to_s)
            self.class.attribute_conditions.each do |attr, options|
              attributes.delete(attr.to_s) if options[:server_only]
            end
            if @_selected_attributes && !@_selected_attributes.empty?
              attributes.each_key do |attr|
                unless @_selected_attributes.include?(attr.to_sym) || @_selected_attributes.include?(attr)
                  attributes.delete(attr)
                end
              end
            end
            if @_excluded_attributes && !@_excluded_attributes.empty?
              @_excluded_attributes.each { |attr| attributes.delete(attr.to_s) }
            end
            attributes
          end
        end
      end
    end
  end
end
