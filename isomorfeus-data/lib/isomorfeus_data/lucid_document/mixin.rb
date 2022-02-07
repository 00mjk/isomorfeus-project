module LucidDocument
  module Mixin
    def self.included(base)
      base.include(Isomorfeus::Data::FieldSupport)
      base.extend(Isomorfeus::Data::GenericClassApi)
      base.include(Isomorfeus::Data::GenericInstanceApi)

      base.instance_exec do
        def escape_string(s)
          s.gsub(/([\\\&\:\(\)\[\]\{\}\!\"\~\^\|\<\>\=\*\?\+\-\s])/, '\\\\\1')
        end
      end

      def [](name)
        send(name)
      end

      def []=(name, val)
        send("#{name}=", val)
      end

      def changed!
        @_changed = true
      end

      def to_transport
        hash = { 'fields' => _get_selected_fields }
        hash['revision'] = revision if revision
        result = { @class_name => { @key => hash }}
        result.deep_merge!(@class_name => { @previous_key => { new_key: @key}}) if @previous_key
        result
      end

      if RUBY_ENGINE == 'opal'
        def initialize(key: nil, revision: nil, fields: nil, _loading: false)
          @key = key.nil? ? SecureRandom.uuid : key.to_s
          @class_name = self.class.name
          @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
          _update_paths
          @_revision = revision ? revision : Redux.fetch_by_path(:data_state, :revision, @class_name, @key)
          @_changed = false
          loaded = loaded?
          if loaded
            raw_fields = Redux.fetch_by_path(*@_store_path)
            if `raw_fields === null`
              if fields
                _validate_fields(fields)
                @_changed_fields = fields
              else
                @_changed_fields = {}
              end
            elsif raw_fields && fields && ::Hash.new(raw_fields) != fields
              _validate_fields(fields)
              @_changed_fields = fields
            else
              @_changed_fields = {}
            end
          else
            fields = {} unless fields
            _validate_fields(fields) unless _loading
            @_changed_fields = fields
          end
        end

        def _load_from_store!
          @_changed_fields = {}
          @_changed = false
        end

        def _update_paths
          @_store_path = [:data_state, @class_name, @key, :fields]
        end

        def each(&block)
          fields.each(&block)
        end
      else # RUBY_ENGINE
        Isomorfeus.add_valid_data_class(base) unless base == LucidDocument::Base

        base.instance_exec do
          def instance_from_transport(instance_data, _included_items_data)
            key = instance_data[self.name].keys.first
            revision = instance_data[self.name][key].key?('revision') ? instance_data[self.name][key]['revision'] : nil
            fields = instance_data[self.name][key].key?('fields') ? instance_data[self.name][key]['fields'].transform_keys!(&:to_sym) : nil
            new(key: key, revision: revision, fields: fields)
          end

          def setup_index(&block)
            @_setup_index_block = block
          end

          def ferret_accelerator
            return @ferret_accelerator if @ferret_accelerator
            @ferret_accelerator = if @_setup_index_block
                                    Isomorfeus::Data::DocumentAccelerator.new(self, &@_setup_index_block)
                                  else
                                    Isomorfeus::Data::DocumentAccelerator.new(self)
                                  end
          end

          def search(query, options = {})
            top_docs = []
            self.ferret_accelerator.search_each(query, options) do |id|
              doc = self.ferret_accelerator.index.doc(id)&.load
              if doc
                key = doc.delete(:key)
                top_docs << self.new(key: key, fields: doc)
              end
            end
            top_docs
          end

          execute_create do
            doc = self.fields.dup
            if self.key.nil?
              u = SecureRandom.uuid
              doc[:key] = u
              self.key = u
            else
              doc[:key] = self.key
            end
            self.class.ferret_accelerator.create_doc(doc)
            self
          end

          execute_destroy do |key:|
            self.ferret_accelerator.destroy_doc(key)
          end

          execute_load do |key:|
            doc = self.ferret_accelerator.load_doc(key)
            if doc
              doc.delete(:key)
              self.new(key: key, fields: doc)
            end
          end

          execute_save do
            doc = self.fields.dup
            if self.key.nil?
              u = SecureRandom.uuid
              doc[:key] = u
              self.key = u
              self.class.ferret_accelerator.create_doc(doc)
            else
              doc[:key] = self.key
              self.class.ferret_accelerator.save_doc(self.key, doc)
            end
            self
          end
        end

        def initialize(key: nil, revision: nil, fields: nil)
          @key = key.nil? ? SecureRandom.uuid : key.to_s
          @class_name = self.class.name
          @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
          @_revision = revision
          @_changed = false
          fields = {} unless fields
          _validate_fields(fields)
          @_raw_fields = fields
        end

        def _unchange!
          @_changed = false
        end

        def each(&block)
          @_raw_fields.each(&block)
        end

        def reload
          new_instance = self.class.load(key: @key)
          @_raw_fields = new_instance.fields
          _unchange!
          self
        end
      end # RUBY_ENGINE
    end
  end
end
