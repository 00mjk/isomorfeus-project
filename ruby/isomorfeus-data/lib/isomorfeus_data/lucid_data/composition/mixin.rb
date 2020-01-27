module LucidData
  module Composition
    module Mixin
      # TODO nodes -> documents
      # TODO include -> compose dsl
      # TODO inline store path
      def self.included(base)
        base.include(Isomorfeus::Data::AttributeSupport)
        base.extend(Isomorfeus::Data::GenericClassApi)
        base.include(Isomorfeus::Data::GenericInstanceApi)

        base.instance_exec do
          def parts
            @parts ||= {}
          end

          def compose_with(access_name, validate_hash = {})
            parts[access_name] = validate_hash

            define_method(access_name) do
              parts[access_name]
            end

            define_method("#{access_name}=") do |part|
              part_conditions = self.class.parts[access_name]
              Isomorfeus::Data::ElementValidator.new(self.name, part, part_conditions).validate!
              @_changed = true
              parts[access_name] = part
              parts[access_name].composition = self
              parts[access_name]
            end

            define_singleton_method("valid_#{access_name}?") do |part|
              _validate(access_name, part)
            rescue
              false
            end
          end

          def _validate_part(access_name, part)
            Isomorfeus.raise_error(message: "#{self.name}: No such part declared: '#{access_name}'!") unless parts.key?(access_name)
            Isomorfeus::Data::ElementValidator.new(self.name, part, parts[access_name]).validate!
          end

          def _validate_parts(many_parts)
            parts.each_key do |access_name|
              if parts[access_name].key?(:required) && parts[access_name][:required] && !many_parts.key?(attr)
                Isomorfeus.raise_error(message: "Required part #{access_name} not given!")
              end
            end
            many_parts.each { |access_name, part| _validate_part(access_name, part) } if parts.any?
          end
        end

        def _validate_part(access_name, part)
          self.class._validate_part(access_name, part)
        end

        def _validate_parts(many_parts)
          self.class._validate_parts(many_parts)
        end

        def changed?
          @_changed
        end

        def changed!
          @_changed = true
        end

        def to_transport
          hash = { 'attributes' => _get_selected_attributes, 'parts' => {} }
          hash.merge!('revision' => revision) if revision
          parts.each do |name, instance|
            hash['parts'][name.to_s] = instance.to_sid if instance
          end
          result = { @class_name => { @key => hash }}
          result.deep_merge!(@class_name => { @previous_key => { new_key: @key}}) if @previous_key
          result
        end

        def included_items_to_transport
          hash = {}
          parts.each_value do |instance|
            if instance
              hash.deep_merge!(instance.to_transport)
              hash.deep_merge!(instance.included_items_to_transport) if instance.respond_to?(:included_items_to_transport)
            end
          end
          hash
        end

        if RUBY_ENGINE == 'opal'
          def initialize(key:, revision: nil, attributes: nil, parts: nil)
            @key = key.to_s
            @class_name = self.class.name
            @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
            _update_paths
            @_revision = revision ? revision : Redux.fetch_by_path(:data_state, @class_name, @key, :revision)
            @_changed = false

            loaded = loaded?

            if attributes
              _validate_attributes(attributes)
              if loaded
                raw_attributes = Redux.fetch_by_path(*@_store_path)
                if `raw_attributes === null`
                  @_changed_attributes = !attributes ? {} : attributes
                elsif raw_attributes && !attributes.nil? && ::Hash.new(raw_attributes) != attributes
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
              _validate_parts(parts)
              self.class.parts.each_key do |access_name|
                if parts.key?(access_name)
                  part = parts[access_name]
                  @_parts[access_name] = if part.respond_to?(:to_sid)
                                           part
                                         else
                                           Isomorfeus.instance_from_sid(part)
                                         end
                end
              end
            elsif loaded
              self.class.parts.each_key do |access_name|
                sid = Redux.fetch_by_path(*(@_parts_path + [access_name]))
                @_parts[access_name] = Isomorfeus.instance_from_sid(sid) if sid
              end
            end
            @_parts.each_value { |part| part.composition = self }
          end

          def _load_from_store!
            @_changed = false
            @_changed_attributes = {}
            @_parts = {}
            nil
          end

          def _update_paths
            @_store_path = [:data_state, @class_name, @key, :attributes]
            @_parts_path = [:data_state, @class_name, @key, :parts]
          end

          def _init_parts
            self.class.parts.each_key do |access_name|
              sid = Redux.fetch_by_path(*(@_parts_path + [access_name]))
              if sid
                @_parts[access_name] = Isomorfeus.instance_from_sid(sid)
                @_parts[access_name].composition = self
              end
            end
          end

          def parts
            _init_parts if @_parts.empty?
            @_parts
          end

          def parts_as_sids
            Redux.fetch_by_path(*@_composition_path)
          end
        else # RUBY_ENGINE
          Isomorfeus.add_valid_data_class(base) unless base == LucidData::Composition::Base

          base.instance_exec do
            def instance_from_transport(instance_data, included_items_data)
              key = instance_data[self.name].keys.first
              revision = instance_data[self.name][key].key?('revision') ? instance_data[self.name][key]['revision'] : nil
              attributes = instance_data[self.name][key].key?('attributes') ? instance_data[self.name][key]['attributes'] : nil
              source_parts = instance_data[self.name][key].key?('parts') ? instance_data[self.name][key]['parts'] : {}
              parts = {}
              source_parts.each do |part_name, sid|
                part_class_name = sid[0]
                part_key = sid[1]
                Isomorfeus.raise_error "#{self.name}: #{part_class_name}: Not a valid LucidData class!" unless Isomorfeus.valid_data_class_name?(part_class_name)
                if included_items_data.key?(part_class_name) && included_items_data[part_class_name].key?(part_key)
                  part_class = Isomorfeus.cached_data_class(part_class_name)
                  Isomorfeus.raise_error "#{self.name}: #{part_class_name}: Cannot get class!" unless part_class
                  part = part_class.instance_from_transport({ part_class_name => { part_key => included_items_data[part_class_name][part_key] }}, included_items_data)
                  Isomorfeus.raise_error "#{self.name}: #{part_class_name} with key #{part_key} could not be extracted from transport data!" unless part
                  parts[part_name.to_sym] = part
                end
              end
              new(key: key, revision: revision, attributes: attributes, parts: parts)
            end
          end

          def initialize(key:, revision: nil, attributes: nil, parts: nil)
            @key = key.to_s
            @class_name = self.class.name
            @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
            @_revision = revision
            @_changed = false
            @_validate_attributes = self.class.attribute_conditions.any?
            attributes = {} unless attributes
            _validate_attributes(attributes) if attributes.any?
            @_raw_attributes = attributes

            @_parts = {}
            _validate_parts(parts)
            self.class.parts.each_key do |access_name|
              if parts.key?(access_name)
                @_parts[access_name] = parts[access_name]
                @_parts[access_name].composition = self
              end
            end
          end

          def _unchange!
            @_changed = false
          end

          def parts
            @_parts
          end

          def parts_as_sids
            parts.map { |part| part.to_sid }
          end
        end # RUBY_ENGINE
      end
    end
  end
end
