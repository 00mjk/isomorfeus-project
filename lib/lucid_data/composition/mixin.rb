module LucidData
  module Composition
    module Mixin
      # TODO nodes -> documents
      # TODO include -> compose dsl
      # TODO inline store path
      def self.included(base)
        base.extend(LucidPropDeclaration::Mixin)
        base.include(Isomorfeus::Data::AttributeSupport)
        base.extend(Isomorfeus::Data::GenericClassApi)
        base.include(Isomorfeus::Data::GenericInstanceApi)

        base.instance_exec do
          def parts
            @parts ||= {}
          end

          def compose_with(access_name, part_class = nil)
            parts[access_name] = part_class

            define_method(access_name) do
              @_parts[access_name]
            end

            define_method("#{access_name}=") do |part|
              @_changed = true
              @_parts[access_name] = part
              @_parts[access_name].composition = self
              @_parts[access_name]
            end
          end
        end

        def parts
          @_parts
        end

        def changed?
          @_changed
        end

        def changed!
          @_changed = true
        end

        def to_transport
          hash = { attributes: _get_attributes, parts: {} }
          rev = revision
          hash.merge!(_revision: rev) if rev
          parts.each do |name, instance|
            hash[:parts][name] = instance.to_sid
          end
          { @class_name => { @key => hash }}
        end

        def included_items_to_transport
          hash = {}
          parts.each_value do |instance|
            hash.merge!(instance.to_transport)
            hash.merge!(instance.included_items_to_transport) if instance.respond_to?(:included_items_to_transport)
          end
          hash
        end

        if RUBY_ENGINE == 'opal'
          def initialize(key:, revision: nil, attributes: nil, parts: nil)
            @key = key.to_s
            @class_name = self.class.name
            @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
            @_store_path = [:data_state, @class_name, @key, :attributes]
            @_parts_path = [:data_state, @class_name, @key, :parts]
            @_revision = revision ? revision : Redux.fetch_by_path(:data_state, @class_name, @key, :revision)
            @_changed = false

            loaded = loaded?

            if attributes
              attributes.each { |a,v| _validate_attribute(a, v) }
              if loaded
                raw_attributes = Redux.fetch_by_path(*@_store_path)
                if `raw_attributes === null`
                  @_changed_attributes = !attributes ? {} : attributes
                elsif raw_attributes && !attributes.nil? && Hash.new(raw_attributes) != attributes
                  @_changed_attributes = attributes
                end
              else
                @_changed_attributes = attributes
              end
            else
              @_changed_attributes = {}
            end

            @_parts = {}
            if parts && loaded
              self.class.composition.each_key do |access_name|
                if composition.key?(access_name)
                  part = parts[access_name]
                  @_parts[access_name] = if part.respond_to?(:to_sid)
                                           part
                                         else
                                           Isomorfeus.instance_from_sid(part)
                                         end
                end
              end
            elsif loaded
              self.class.composition.each_key do |access_name|
                sid = Redux.fetch_by_path(*@_parts_path.push(access_name))
                @_parts[access_name] = Isomorfeus.instance_from_sid(sid)
              end
            end
            @_parts.each_value { |part| part.composition = self }
          end

          def parts_as_sids
            Redux.fetch_by_path(*@_composition_path)
          end
        else # RUBY_ENGINE
          unless base == LucidData::Composition::Base
            Isomorfeus.add_valid_data_class(base)
            base.prop :pub_sub_client, default: nil
            base.prop :current_user, default: Anonymous.new
          end

          base.instance_exec do
            def load(key:, pub_sub_client: nil, current_user: nil)
              data = instance_exec(key: key, &@_load_block)
              revision = nil
              revision = data.delete(:_revision) if data.key?(:_revision)
              revision = data.delete(:revision) if !revision && data.key?(:revision)
              attributes = data.delete(:attributes)
              parts = data.delete(:parts)
              self.new(key: key, revision: revision, parts: parts, attributes: attributes)
            end
          end

          def initialize(key:, revision: nil, attributes: nil, parts: nil)
            @key = key
            @class_name = self.class.name
            @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
            @_revision = revision
            @_changed = false
            @_validate_attributes = self.class.attribute_conditions.any?
            attributes = {} unless attributes
            if @_validate_attributes
              attributes.each { |a,v| _validate_attribute(a, v) }
            end
            @_raw_attributes = attributes

            @_parts = {}
            self.class.parts.each_key do |access_name|
              if parts.key?(access_name)
                @_parts[access_name] = parts[access_name]
                @_parts[access_name].composition = self
              end
            end
          end

          def parts_as_sids
            parts.map { |part| part.to_sid }
          end
        end # RUBY_ENGINE
      end
    end
  end
end
