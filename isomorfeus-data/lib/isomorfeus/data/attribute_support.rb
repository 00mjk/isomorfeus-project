module Isomorfeus
  module Data
    module AttributeSupport
      def self.included(base)
        base.instance_exec do
          def attribute_conditions
            @attribute_conditions ||= {}
          end

          def indexed_attributes
            @indexed_attributes ||= {}
          end

          def valid_attribute?(attr_name, val)
            Isomorfeus::Props::Validator.new(self.name, attr_name, val, attribute_conditions[attr_name]).validate!
          rescue
            false
          end

          def validate
            Isomorfeus::Props::ValidateHashProxy.new
          end

          def _validate_attribute(attr_name, val)
            Isomorfeus.raise_error(message: "#{self.name}: No such attribute declared: '#{attr_name}'!") unless attribute_conditions.key?(attr_name)
            Isomorfeus::Props::Validator.new(self.name, attr_name, val, attribute_conditions[attr_name]).validated_value
          end

          def _validate_attributes(attrs)
            attribute_conditions.each_key do |attr_name|
              if attribute_conditions[attr_name].key?(:required) && attribute_conditions[attr_name][:required] && !attrs.key?(attr_name)
                Isomorfeus.raise_error(message: "Required attribute #{attr_name} not given!")
              end
              attrs[attr_name] = _validate_attribute(attr_name, attrs[attr_name])
            end
          end
        end

        def _validate_attribute(attr_name, val)
          self.class._validate_attribute(attr_name, val)
        end

        def _validate_attributes(attrs)
          self.class._validate_attributes(attrs)
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
              indexed_attributes[name] = options.delete(:index) if options.key?(:index)
              attribute_conditions[name] = options

              define_method(name) do
                _get_attribute(name)
              end

              define_method("#{name}=") do |val|
                val = _validate_attribute(name, val)
                changed!
                @_changed_attributes[name] = val
              end
            end
          end

          def validate_attributes_function
            %x{
              if (typeof self.validate_attributes_function === 'undefined') {
                self.validate_attributes_function = function(attributes_object) {
                  try { self.$_validate_attributes(Opal.Hash.$new(attributes_object)) }
                  catch (e) { return e.message; }
                }
              }
              return self.validate_attributes_function;
            }
          end

          def validate_attribute_function(attr)
            function_name = "validate_attribute_#{attr}_function"
            %x{
              if (typeof self[function_name] === 'undefined') {
                self[function_name] = function(value) {
                  try { self.$_validate_attribute(attribute, value); }
                  catch (e) { return e.message; }
                }
              }
              return self[function_name];
            }
          end

          def _get_attribute(name)
            return @_changed_attributes[name] if @_changed_attributes.key?(name)
            path = @_store_path + [name]
            result = Redux.fetch_by_path(*path)
            %x{
              if (result === null) { return nil; }
              else if (result instanceof Object && !(result instanceof Array)) {
                return Opal.Hash.$new(result);
              } else { return result; }
            }
          end

          def attributes
            raw_attributes = Redux.fetch_by_path(*@_store_path)
            hash = Hash.new(raw_attributes)
            hash.merge!(@_changed_attributes) if @_changed_attributes
            hash
          end

          def _get_selected_attributes
            sel_attributes = attributes.dup
            if @_selected_attributes && !@_selected_attributes.empty?
              sel_attributes.each_key do |attr|
                unless @_selected_attributes.include?(attr) || @_selected_attributes.include?(attr)
                  sel_attributes.delete(attr)
                end
              end
            end
            if @_excluded_attributes && !@_excluded_attributes.empty?
              @_excluded_attributes.each { |attr| sel_attributes.delete(attr) }
            end
            sel_attributes
          end
        else
          base.instance_exec do
            def attribute(name, options = {})
              indexed_attributes[name] = options.delete(:index) if options.key?(:index)
              attribute_conditions[name] = options

              define_method(name) do
                @_raw_attributes[name]
              end

              define_method("#{name}=") do |val|
                val = _validate_attribute(name, val)
                changed!
                @_raw_attributes[name] = val
              end
            end
          end

          def attributes
            @_raw_attributes
          end

          def _get_selected_attributes
            sel_attributes = attributes.transform_keys(&:to_s)
            self.class.attribute_conditions.each do |attr, options|
              sel_attributes.delete(attr.to_s) if options[:server_only]
            end
            if @_selected_attributes && !@_selected_attributes.empty?
              sel_attributes.each_key do |attr|
                unless @_selected_attributes.include?(attr.to_sym) || @_selected_attributes.include?(attr)
                  sel_attributes.delete(attr)
                end
              end
            end
            if @_excluded_attributes && !@_excluded_attributes.empty?
              @_excluded_attributes.each { |attr| sel_attributes.delete(attr.to_s) }
            end
            sel_attributes
          end
        end
      end
    end
  end
end
