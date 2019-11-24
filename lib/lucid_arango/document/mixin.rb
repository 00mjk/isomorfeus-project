module LucidArango
  module Document
    module Mixin
      def self.included(base)
        base.include(Enumerable)
        base.extend(LucidPropDeclaration::Mixin)
        base.extend(Isomorfeus::Data::GenericClassApi)
        base.include(Isomorfeus::Data::GenericInstanceApi)
        # TODO implement, depends on arango-driver

        base.instance_exec do
          def _handler_type
            'document'
          end

          def attribute_conditions
            @attribute_conditions ||= {}
          end

          def valid_attribute?(attr_name, attr_value)
            return true unless @attribute_conditions
            Isomorfeus::Props::Validator.new(self.name, attr_name, attr_value, attribute_conditions[attr_name]).validate!
          rescue
            false
          end
        end

        def to_transport
          { @class_name => { @key => to_h }}
        end

        def _validate_attribute(attr_name, attr_val)
          Isomorfeus::Props::Validator.new(@class_name, attr_name, attr_val, self.class.attribute_conditions[attr_name]).validate!
        end

        if RUBY_ENGINE == 'opal'
          base.instance_exec do
            def attribute(name, options = {})
              attribute_conditions[name] = options

              define_method(name) do
                path = @_store_path + [name]
                result = Redux.fetch_by_path(*path)
                if result
                  result
                elsif !@_default_proc
                  @_default
                else
                  @_default_proc.call(self, name)
                end
              end

              define_method("#{name}=") do |val|
                _validate_attribute(name, val) if @_validate_attributes
                _update_attribute(name, val)
                val
              end
            end
          end

          def initialize(key:, revision: nil,  attributes: nil)
            @key = key.to_s
            @class_name = self.class.name
            @_store_path = [:data_state, @class_name, @key]
            @_changed_store_path = [:data_state, :changed, @class_name, @key]
            @_revision_store_path = [:data_state, :revision, @class_name, @key]
            attributes = {} unless attributes
            attributes.each { |a,v| _validate_attribute(a, v) }
            Isomorfeus.store.dispatch(type: 'DATA_LOAD', data: { @class_name => { @key => attributes },
                                                                 changed: { @class_name => { @key => false }},
                                                                 revision: { @class_name => { @key => revision }}})
          end

        else # RUBY_ENGINE
          unless base == LucidArango::Document::Base
            Isomorfeus.add_valid_document_class(base)
            base.prop :pub_sub_client, default: nil
            base.prop :current_user, default: Anonymous.new
          end
        end
      end
    end
  end
end
