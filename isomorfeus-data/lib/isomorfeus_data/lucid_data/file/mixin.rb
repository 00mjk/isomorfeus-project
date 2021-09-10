module LucidData
  module File
    module Mixin
      def self.included(base)
        base.extend(Isomorfeus::Data::GenericClassApi)
        base.include(Isomorfeus::Data::GenericInstanceApi)
        
        def changed!
          @_changed = true
        end

        def to_transport
          hash = {}
          hash['revision'] = revision if revision
          hash['data_uri'] = data_uri
          result = { @class_name => { @key => hash }}
          result.deep_merge!(@class_name => { @previous_key => { new_key: @key }}) if @previous_key
          result
        end

        def content_type
          URI::Data.new(datra_uri).content_type if data_uri
          nil
        end

        def content_type=(c)
          if data_uri
            # TODO: just do some string manipulation instead
            data_uri = URI::Data.build(content_type: c, data: data)
          else
            @_content_type = c
          end
        end

        def data_uri
          return @_changed_data_uri if @_changed_data_uri
          @_data_uri
        end

        def data_uri=(d)
          @_changed = true
          @_changed_data_uri=d
        end

        def data
          URI::Data.new(data_uri).data if data_uri
          nil
        end

        def data=(d, content_type: nil)
          if @_content_type || content_type
            data_uri = URI::Data.build(content_type: (content_type ? content_type : @_content_type), data: d)
          else
            data_uri = URI::Data.build(data: d)
          end
        end

        if RUBY_ENGINE == 'opal'
          base.instance_exec do
            def files_path
            end
  
            def files_path=(_)
            end
          end

          def initialize(key:, data: nil, data_uri: nil, revision: nil, composition: nil)
            @key = key.to_s
            @class_name = self.class.name
            @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
            _update_paths
            @_revision = revision ? revision : Redux.fetch_by_path(:data_state, :revision, @class_name, @key)
            @_composition = composition
            if data
              self.data = data
            else
              @_data_uri = data_uri
            end
            @_changed = false
            loaded = loaded?
            @_changed_data_uri = nil
          end
    
          def _load_from_store!
            @_changed_data_uri = nil
            @_changed = false
          end
    
          def _update_paths
            @_store_path = [:data_state, @class_name, @key, :data_uri]
          end
    
          def data_uri
            return @changed_data_uri if @changed_data_uri
            Redux.fetch_by_path(*@_store_path)
          end
        else # RUBY_ENGINE
          Isomorfeus.add_valid_file_class(base) unless base == LucidData::File::Base

          base.instance_exec do
            def instance_from_transport(instance_data, _included_items_data)
              key = instance_data[self.name].keys.first
              revision = instance_data[self.name][key].key?('revision') ? instance_data[self.name][key]['revision'] : nil
              data_uri = instance_data[self.name][key].key?('data_uri') ? instance_data[self.name][key]['data_uri'].transform_keys!(&:to_sym) : nil
              new(key: key, revision: revision, data_uri: data_uri)
            end

            def files_path
              @files_path ||= Isomorfeus.files_path
            end
  
            def files_path=(f)
              @files_path = f
            end
          end

          def initialize(key:, data: nil, data_uri: nil, revision: nil, composition: nil)
            @key = key.to_s
            @class_name = self.class.name
            @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
            @_revision = revision
            @_composition = composition
            @_changed = false
            @_changed_data_uri = nil
            if data
              self.data = data
            else
              @_data_uri = data_uri
            end
          end
  
          def _unchange!
            @_changed = false
          end

          base.execute_create do
            self.save
          end

          base.execute_destroy do |key:|
            FileUtils.rm_f(File.join(files_path, key))
          end

          base.execute_load do |key:|
            data = File.read(File.join(files_path, key))
            instance = self.new(key: key)
            instance.data = data
            instance
          end

          base.execute_save do
            File.write(File.join(files_path, key), data)
            self
          end
        end # RUBY_ENGINE
      end
    end
  end
end
