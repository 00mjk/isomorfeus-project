module LucidFile
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
        _reload
        return @_data_uri_object.content_type if @_data_uri_object
        nil
      end

      def content_type=(c)
        changed!
        _content_type(c)
      end

      def _content_type(c)
        _reload
        @_data_uri_string = _format_data_uri(c, @_data_uri_object.data)
        @_data_uri_object = URI::Data.new(@_data_uri_string)
        c
      end

      def data
        _reload
        @_data_uri_object.data
      end

      def data=(d)
        changed!
        _data(d)
      end

      def _data(d)
        _reload
        @_data_uri_string = _format_data_uri(self.content_type, d)
        @_data_uri_object = URI::Data.new(@_data_uri_string)
        d
      end

      def data_uri
        _reload
        @_data_uri_string
      end

      def data_uri=(d)
        changed!
        _data_uri(d)
      end

      def _data_uri(d)
        _reload
        if d.class == URI::Data
          @_data_uri_string = _format_data_uri(d.content_type, d.data)
          @_data_uri_object = d
        else
          @_data_uri_string = d
          @_data_uri_object = URI::Data.new(d)
        end
        @_data_uri_string
      end

      def data_uri_object
        _reload
        @_data_uri_object
      end

      def _format_data_uri(c, d)
        "data:#{c};base64,#{Base64.encode64(d).chop}"
      end

      if RUBY_ENGINE == 'opal'
        base.instance_exec do
          def files_path
          end

          def files_path=(_)
          end
        end

        def initialize(key: nil, content_type: nil, data: nil, data_uri: nil, revision: nil, _loading: false)
          @key = key.nil? ? SecureRandom.uuid : key.to_s
          @class_name = self.class.name
          @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
          _update_paths
          @_revision = revision ? revision : Redux.fetch_by_path(:data_state, :revision, @class_name, @key)
          @_changed = false
          @_reload = false
          loaded = loaded?
          @_data_uri_object = nil
          @_data_uri_string = nil
          if data_uri
            self.data_uri = data_uri
          elsif data
            self.data = data
            self.content_type = content_type if content_type
          else
            self._data('')
            self._content_type(content_type) if content_type
          end
        end

        def _load_from_store!
          @_changed = false
          @_reload = true
        end

        def _reload
          return unless @_reload
          @_reload = false
          d = Redux.fetch_by_path(*@_store_path)
          self._data_uri(d) if d
        end

        def _update_paths
          @_store_path = [:data_state, @class_name, @key, :data_uri]
        end
      else # RUBY_ENGINE
        Isomorfeus.add_valid_file_class(base) unless base == LucidFile::Base

        base.instance_exec do
          def instance_from_transport(instance_data, _included_items_data)
            key = instance_data[self.name].keys.first
            revision = instance_data[self.name][key].key?('revision') ? instance_data[self.name][key]['revision'] : nil
            data_uri = instance_data[self.name][key].key?('data_uri') ? instance_data[self.name][key]['data_uri'] : nil
            new(key: key, revision: revision, data_uri: data_uri)
          end

          def files_path
            @files_path ||= Isomorfeus.files_path
          end

          def files_path=(f)
            @files_path = f
          end

          def check_and_prepare_path(key:)
            Isomorfeus.raise_error(message: 'Invalid key (contains ".." or "\\")') if key.include?('..') || key.include?('\\')
            elements = key.split('/')
            Isomorfeus.raise_error(message: 'Invalid key (contains more than 2 slashes "/")') if elements.size > 3
            file = elements.pop
            if elements.size > 0
              dir_path = ::File.expand_path(::File.join(files_path, *elements))
              FileUtils.mkdir_p(path) unless Dir.exist?(dir_path)
              ::File.join(dir_path, file)
            else
              FileUtils.mkdir_p(files_path) unless Dir.exist?(files_path)
              ::File.join(files_path, file)
            end
          end

          execute_create do
            self.save
          end

          execute_destroy do |key:|
            file = check_and_prepare_path(key: key)
            ::FileUtils.rm_f(file)
            true
          end

          execute_load do |key:|
            file = check_and_prepare_path(key: key)
            d = ::File.read(file)
            instance = self.new(key: key)
            instance.data = d
            instance
          end

          execute_save do
            file = self.class.check_and_prepare_path(key: self.key)
            ::File.write(file, self.data)
            self
          end
        end

        def initialize(key: nil, content_type: nil, data: nil, data_uri: nil, revision: nil)
          @key = key.nil? ? SecureRandom.uuid : key.to_s
          @class_name = self.class.name
          @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
          @_revision = revision
          @_data_uri_object = nil
          @_data_uri_string = nil
          if data_uri
            self._data_uri(data_uri)
          else
            self._data(data ? data : '')
            self._content_type(content_type) if content_type
          end
          @_changed = false
        end

        def _reload
        end

        def _unchange!
          @_data_uri = @_changed_data_uri if @_changed
          @_changed = false
        end
      end # RUBY_ENGINE
    end
  end
end
