module Isomorfeus
  module Data
    module FieldSupport
      def self.included(base)
        base.instance_exec do
          def field_options
            @field_options ||= {}
          end

          def field_conditions
            @field_conditions ||= {}
          end

          def valid_field?(field_name, val)
            Isomorfeus::Props::Validator.new(self.name, field_name, val, field_conditions[field_name]).validate!
          end

          def validate
            Isomorfeus::Props::ValidateHashProxy.new
          end

          def _validate_field(field_name, val)
            Isomorfeus.raise_error(message: "#{self.name}: No such field declared: '#{field_name}'!") unless field_conditions.key?(field_name)
            Isomorfeus::Props::Validator.new(self.name, field_name, val, field_conditions[field_name]).validated_value
          end

          def _validate_fields(fields)
            field_conditions.each_key do |field_name|
              if field_conditions[field_name].key?(:required) && field_conditions[field_name][:required] && !fields.key?(field_name)
                Isomorfeus.raise_error(message: "Required field #{field_name} not given!")
              end
              fields[field_name] = _validate_field(field_name, fields[field_name])
            end
          end
        end

        def _validate_field(field_name, val)
          self.class._validate_field(field_name, val)
        end

        def _validate_fields(fields)
          self.class._validate_fields(fields)
        end

        def exclude_fields(*flds)
          @_excluded_fields = flds
        end

        def select_fields(*flds)
          @_selected_fields = flds
        end

        if RUBY_ENGINE == 'opal'
          base.instance_exec do
            def field(name, options = {})
              field_options[name] = {}
              field_options[name][:default_boost] = options.delete(:default_boost) if options.key?(:default_boost)
              field_options[name][:default_boost] = options.delete(:default_boost) if options.key?(:boost)
              field_options[name][:index] = options.delete(:index) if options.key?(:index)
              field_options[name][:store] = options.delete(:store) if options.key?(:store)
              field_options[name][:term_vector] = options.delete(:term_vector) if options.key?(:term_vector)
              field_conditions[name] = options

              define_method(name) do
                _get_field(name)
              end

              define_method("#{name}=") do |val|
                val = _validate_field(name, val)
                changed!
                @_changed_fields[name] = val
              end
            end
          end

          def validate_fields_function
            %x{
              if (typeof self.validate_fields_function === 'undefined') {
                self.validate_fields_function = function(fields_object) {
                  try { self.$_validate_fields(Opal.Hash.$new(fields_object)) }
                  catch (e) { return e.message; }
                }
              }
              return self.validate_fields_function;
            }
          end

          def validate_field_function(field_name)
            function_name = "validate_field_#{field_name}_function"
            %x{
              if (typeof self[function_name] === 'undefined') {
                self[function_name] = function(value) {
                  try { self.$_validate_field(field_name, value); }
                  catch (e) { return e.message; }
                }
              }
              return self[function_name];
            }
          end

          def _get_field(name)
            return @_changed_fields[name] if @_changed_fields.key?(name)
            path = @_store_path + [name]
            result = Redux.fetch_by_path(*path)
            %x{
              if (result === null) { return nil; }
              else { return result; }
            }
          end

          def fields
            raw_fields = Redux.fetch_by_path(*@_store_path)
            hash = Hash.new(raw_fields)
            hash.merge!(@_changed_fields) if @_changed_fields
            hash
          end

          def _get_selected_fields
            sel_fields = fields.dup
            if @_selected_fields && !@_selected_fields.empty?
              sel_fields.each_key do |fld|
                unless @_selected_fields.include?(fld) || @_selected_fields.include?(fld)
                  sel_fields.delete(fld)
                end
              end
            end
            if @_excluded_fields && !@_excluded_fields.empty?
              @_excluded_fields.each { |fld| sel_fields.delete(fld) }
            end
            sel_fields
          end
        else
          base.instance_exec do
            def field(name, options = {})
              field_options[name] = {}
              field_options[name][:default_boost] = options.delete(:default_boost) if options.key?(:default_boost)
              field_options[name][:default_boost] = options.delete(:default_boost) if options.key?(:boost)
              field_options[name][:index] = options.delete(:index) if options.key?(:index)
              field_options[name][:store] = options.delete(:store) if options.key?(:store)
              field_options[name][:term_vector] = options.delete(:term_vector) if options.key?(:term_vector)
              field_conditions[name] = options

              define_method(name) do
                @_raw_fields[name]
              end

              define_method("#{name}=") do |val|
                val = _validate_field(name, val)
                changed!
                @_raw_fields[name] = val
              end
            end
          end

          def fields
            @_raw_fields
          end

          def _get_selected_fields
            sel_fields = fields.transform_keys(&:to_s)
            if @_selected_fields && !@_selected_fields.empty?
              sel_fields.each_key do |fld|
                unless @_selected_fields.include?(fld.to_sym) || @_selected_fields.include?(fld)
                  sel_fields.delete(fld)
                end
              end
            end
            if @_excluded_fields && !@_excluded_fields.empty?
              @_excluded_fields.each { |fld| sel_fields.delete(fld.to_s) }
            end
            sel_fields
          end
        end
      end
    end
  end
end
