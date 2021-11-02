module Isomorfeus
  module Data
    module FieldSupport
      def self.included(base)
        base.instance_exec do
          def field_options
            @field_options ||= {}
          end

          def valid_field?(field_name, field_value)
            field_options.key?(field_name)
          end
        end

        def exclude_fields(*flds)
          @_excluded_fields = flds
        end

        def select_fields(*flds)
          @_selected_fields = flds
        end

        if RUBY_ENGINE == 'opal'
          base.instance_exec do
            def field(name, options = nil)
              field_options[name] = options

              define_method(name) do
                _get_field(name)
              end

              define_method("#{name}=") do |val|
                val = val.to_s unless val.class == String
                changed!
                @_changed_fields[name] = val
              end
            end
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
              field_options[name] = options

              define_method(name) do
                @_raw_fields[name]
              end

              define_method("#{name}=") do |val|
                val = val.to_s unless val.class == String
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
