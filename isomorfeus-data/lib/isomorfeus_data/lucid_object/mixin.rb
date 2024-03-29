module LucidObject
  module Mixin
    def self.included(base)
      base.include(Isomorfeus::Data::AttributeSupport)
      base.extend(Isomorfeus::Data::GenericClassApi)
      base.include(Isomorfeus::Data::GenericInstanceApi)
      base.include(LucidI18n::Mixin)

      base.instance_exec do
        def store_compressed(quality: 5)
          @_store_compressed = quality
        end

        def _store_compressed
          @_store_compressed
        end
      end

      def [](name)
        send(name)
      end

      def []=(name, val)
        send("#{name}=".to_sym, val)
      end

      def changed!
        @_changed = true
      end

      def to_transport
        hash = { 'attributes' => _get_selected_attributes }
        hash['revision'] = revision if revision
        result = { @class_name => { @key => hash }}
        result.deep_merge!(@class_name => { @previous_key => { new_key: @key}}) if @previous_key
        result
      end

      if RUBY_ENGINE == 'opal'
        def initialize(key: nil, revision: nil, attributes: nil, _loading: false)
          @key = key.nil? ? SecureRandom.uuid : key.to_s
          @class_name = self.class.name
          @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
          _update_paths
          @_revision = revision ? revision : Redux.fetch_by_path(:data_state, :revision, @class_name, @key)
          @_changed = false
          loaded = loaded?
          if loaded
            raw_attributes = Redux.fetch_by_path(*@_store_path)
            if `raw_attributes === null`
              if attributes
                _validate_attributes(attributes)
                @_changed_attributes = attributes
              else
                @_changed_attributes = {}
              end
            elsif raw_attributes && attributes && ::Hash.new(raw_attributes) != attributes
              _validate_attributes(attributes)
              @_changed_attributes = attributes
            else
              @_changed_attributes = {}
            end
          else
            attributes = {} unless attributes
            _validate_attributes(attributes) unless _loading
            @_changed_attributes = attributes
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

          def props_from_data(instance_data)
            key = instance_data[self.name].keys.first
            revision = instance_data[self.name][key].key?('revision') ? instance_data[self.name][key]['revision'] : nil
            attributes = instance_data[self.name][key].key?('attributes') ? instance_data[self.name][key]['attributes'].transform_keys!(&:to_sym) : nil
            LucidProps.new({ key: key, revision: revision }.merge!(attributes))
          end

          def setup_environment(&block)
            @_setup_environment_block = block
          end

          def setup_index(&block)
            @_setup_index_block = block
          end

          def object_expander
            return @object_expander if @object_expander
            compress = _store_compressed
            compress = false if compress.nil?
            @object_expander = if @_setup_environment_block
                                 Isomorfeus::Data::ObjectExpander.new(class_name: self.to_s, compress: compress, &@_setup_index_block)
                               else
                                 Isomorfeus::Data::ObjectExpander.new(class_name: self.to_s, compress: compress)
                               end
          end

          def object_accelerator
            return @object_accelerator if @object_accelerator
            @object_accelerator = if @_setup_index_block
                                     Isomorfeus::Data::ObjectAccelerator.new(self.to_s, &@_setup_index_block)
                                   else
                                     Isomorfeus::Data::ObjectAccelerator.new(self.to_s)
                                   end
          end

          def search(attr, val, options = {})
            idx_type = self.indexed_attributes[attr]
            raise "Can only search indexed attributes, but attribute :#{attr} is not indexed!" unless idx_type
            objs = []
            if idx_type == :text
              query = "+value:#{val} +class_name:#{self.name}"
              query << " +attribute:#{attr}" if attr != '*'
              self.object_accelerator.search_each(query, options) do |id|
                doc = self.object_accelerator.index.doc(id)&.load
                if doc
                  sid_s = doc[:sid_s_attr].split(':|:')[0]
                  obj = self.load(key: sid_s)
                  objs << obj if obj
                end
              end
            else
              if val == '*'
                self.object_expander.each do |obj|
                  objs << obj if obj.class == self
                end
              else
                attr_s = ":[#{attr}]"
                accept_all_attr = attr_s == ":[*]" ? true : false
                self.object_expander.search(":[#{self.name}]:|:[:#{val}:]:") do |sid_s_attr|
                  if accept_all_attr || sid_s_attr.end_with?(attr_s)
                    sid_s = sid_s_attr.split(':|:[')[0]
                    obj = self.load(key: sid_s)
                    objs << obj if obj
                  end
                end
              end
            end
            objs
          end

          execute_create do
            self.key = SecureRandom.uuid unless self.key
            self.class.object_expander.create_object(self.sid_s, self)
            self.class.indexed_attributes.each do |attr, idx_type|
              if idx_type == :text
                self._create_text_indexed_attribute(attr)
              else
                self._store_value_indexed_attribute(attr)
              end
            end
            self
          end

          execute_destroy do |key:|
            key = key.to_s
            sid_s = key.start_with?('[') ? key : gen_sid_s(key)
            self.object_expander.destroy_object(sid_s)
            self.indexed_attributes.each do |attr, idx_type|
              if idx_type == :text
                self.object_accelerator.destroy_doc("#{sid_s}:|:[#{attr}]")
              else
                old_val = self.object_expander.index_get("#{sid_s}:|:[#{attr}]")
                self.object_expander.index_delete("#{sid_s}:|:[#{attr}]", old_val)
                self.object_expander.index_delete(":[#{self.name}]:|:[:#{old_val}:]:", "#{sid_s}:|:[#{attr}]")
              end
            end
            true
          end

          execute_load do |key:|
            key = key.to_s
            sid_s = key.start_with?('[') ? key : gen_sid_s(key)
            self.object_expander.load_object(sid_s)
          end

          execute_save do
            self.key = SecureRandom.uuid unless self.key
            self.class.object_expander.save_object(self.sid_s, self)
            self.class.indexed_attributes.each do |attr, val|
              if val == :text
                self._store_text_indexed_attribute(attr)
              else
                self._store_value_indexed_attribute(attr)
              end
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

        def _create_text_indexed_attribute(attr)
          doc = { sid_s_attr: "#{self.sid_s}:|:[#{attr}]", value: self.send(attr).to_s, attribute: attr.to_s, class_name: @class_name }
          self.class.object_accelerator.create_doc(doc)
        end

        def _store_text_indexed_attribute(attr)
          doc = { sid_s_attr: "#{self.sid_s}:|:[#{attr}]", value: self.send(attr).to_s, attribute: attr.to_s, class_name: @class_name }
          self.class.object_accelerator.save_doc("#{self.sid_s}:|:[#{attr}]", doc)
        end

        def _store_value_indexed_attribute(attr)
          old_val = self.class.object_expander.index_get("#{self.sid_s}:|:[#{attr}]")
          self.class.object_expander.index_delete("#{self.sid_s}:|:[#{attr}]", old_val)
          self.class.object_expander.index_delete(":[#{self.class.name}]:|:[:#{old_val}:]:", "#{self.sid_s}:|:[#{attr}]")
          val = "#{self.send(attr)}"[0..300]
          self.class.object_expander.index_put("#{self.sid_s}:|:[#{attr}]", val)
          self.class.object_expander.index_put(":[#{self.class.name}]:|:[:#{val}:]:", "#{self.sid_s}:|:[#{attr}]")
        end

        def _unchange!
          @_changed = false
        end

        def each(&block)
          @_raw_attributes.each(&block)
        end

        def reload
          new_instance = self.class.load(key: @key)
          @_raw_attributes = new_instance.attributes
          _unchange!
          self
        end
      end # RUBY_ENGINE
    end
  end
end
