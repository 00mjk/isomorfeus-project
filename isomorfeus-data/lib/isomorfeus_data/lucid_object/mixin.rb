module LucidObject
  module Mixin
    def self.included(base)
      base.include(Isomorfeus::Data::AttributeSupport)
      base.extend(Isomorfeus::Data::GenericClassApi)
      base.include(Isomorfeus::Data::GenericInstanceApi)

      def changed!
        @_changed = true
      end

      def [](name)
        send(name)
      end

      def []=(name, val)
        send("#{name}=".to_sym, val)
      end

      def to_transport
        hash = { 'attributes' => _get_selected_attributes }
        hash['revision'] = revision if revision
        result = { @class_name => { @key => hash }}
        result.deep_merge!(@class_name => { @previous_key => { new_key: @key}}) if @previous_key
        result
      end

      if RUBY_ENGINE == 'opal'
        def initialize(key: nil, revision: nil, attributes: nil)
          @key = key.nil? ? SecureRandom.uuid : key.to_s
          @class_name = self.class.name
          @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
          _update_paths
          @_revision = revision ? revision : Redux.fetch_by_path(:data_state, :revision, @class_name, @key)
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
        end

        def _load_from_store!
          @_changed_attributes = {}
          @_changed = false
        end

        def _update_paths
          @_store_path = [:data_state, @class_name, @key, :attributes]
        end

        def each(&block)
          attributes.each(&block)
        end
      else # RUBY_ENGINE
        Isomorfeus.add_valid_data_class(base) unless base == LucidObject::Base

        base.instance_exec do
          def instance_from_transport(instance_data, _included_items_data)
            key = instance_data[self.name].keys.first
            revision = instance_data[self.name][key].key?('revision') ? instance_data[self.name][key]['revision'] : nil
            attributes = instance_data[self.name][key].key?('attributes') ? instance_data[self.name][key]['attributes'].transform_keys!(&:to_sym) : nil
            new(key: key, revision: revision, attributes: attributes)
          end

          def setup_environment(&block)
            @_setup_environment_block = block
          end

          def hamster_storage_expander
            return @hamster_storage_expander if @hamster_storage_expander
            @hamster_storage_expander = if @_setup_environment_block
                                          Isomorfeus::Data::HamsterStorageExpander.new(&@_setup_index_block)
                                        else
                                          Isomorfeus::Data::HamsterStorageExpander.new
                                        end
          end

          def search(attr, val)
            raise "Can only search indexed attributes, but attribute '#{attr}' is not indexed!" unless self.indexed_attributes.key?(attr)
            objs = []
            attr_s = ":[#{attr}]"
            accept_all_attr = attr_s == ":[*]" ? true : false
            self.hamster_storage_expander.search(":[:#{val}:]:") do |sid_s_attr|
              if accept_all_attr || sid_s_attr.end_with?(attr_s)
                sid_s = sid_s_attr.split(':|:[', 1)[0]
                objs << self.load(sid_s)
              end
            end
            objs
          end

          execute_create do
            self.key = SecureRandom.uuid unless self.key
            self.class.hamster_storage_expander.create_object(self.sid_s, self)
            self.class.indexed_attributes.each_key do |attr|
              self._store_indexed_attribute(attr)
            end
            self
          end

          execute_destroy do |key:|
            key = key.to_s
            sid_s = key.start_with?('[') ? key : gen_sid_s(key)
            self.hamster_storage_expander.destroy_object(sid_s)
            self.indexed_attributes.each_key do |attr|
              old_val = self.hamster_storage_expander.index_get("#{sid_s}:|:[#{attr}]")
              self.hamster_storage_expander.index_delete("#{sid_s}:|:[#{attr}]", old_val)
              self.hamster_storage_expander.index_delete(":[:#{old_val}:]:", "#{sid_s}:|:[#{attr}]")
            end
            true
          end

          execute_load do |key:|
            key = key.to_s
            sid_s = key.start_with?('[') ? key : gen_sid_s(key)
            self.hamster_storage_expander.load_object(sid_s)
          end

          execute_save do
            self.key = SecureRandom.uuid unless self.key
            self.class.hamster_storage_expander.save_object(self.sid_s, self)
            self.class.indexed_attributes.each_key do |attr|
              self._store_indexed_attribute(attr)
            end
            self
          end
        end

        def initialize(key: nil, revision: nil, attributes: nil)
          @key = key.nil? ? SecureRandom.uuid : key.to_s
          @class_name = self.class.name
          @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
          @_revision = revision
          @_changed = false
          attributes = {} unless attributes
          _validate_attributes(attributes) if attributes
          @_raw_attributes = attributes
        end

        def _store_indexed_attribute(attr)
          old_val = self.class.hamster_storage_expander.index_get("#{self.sid_s}:|:[#{attr}]")
          self.class.hamster_storage_expander.index_delete("#{self.sid_s}:|:[#{attr}]", old_val)
          self.class.hamster_storage_expander.index_delete(":[:#{old_val}:]:", "#{self.sid_s}:|:[#{attr}]")
          val = "#{self.send(attr)}"[0..300]
          self.class.hamster_storage_expander.index_put("#{self.sid_s}:|:[#{attr}]", val)
          self.class.hamster_storage_expander.index_put(":[:#{val}:]:", "#{self.sid_s}:|:[#{attr}]")
        end

        def _unchange!
          @_changed = false
        end

        def each(&block)
          @_raw_attributes.each(&block)
        end
      end # RUBY_ENGINE
    end
  end
end