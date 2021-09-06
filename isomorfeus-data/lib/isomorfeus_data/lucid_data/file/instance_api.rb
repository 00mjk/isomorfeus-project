module LucidData
  module File
    module InstanceApi
      def self.included(base)
        def key
          @key
        end

        def key=(k)
          @key = k.to_s
        end

        def revision
          @_revision
        end

        def to_sid
          [@class_name, @key]
        end

        def changed?
          @_changed
        end

        def changed!
          @_changed = true
        end

        def to_transport
          hash = { 'attributes' => _get_selected_attributes }
          hash['revision'] = revision if revision
          hash['derivatives'] = {}
          derivatives.each do |derivative|
            u = url(derivative: derivative)
            hash['derivatives'][derivative]['url'] = u if u
            u = data_url(derivative: derivative)
            hash['derivatives'][derivative]['data_url'] = u if du
            d = data(derivative: derivative)
            hash['derivatives'][derivative]['data'] = Base64.encode64(d) if d
          end
          result = { @class_name => { @key => hash }}
          result.deep_merge!(@class_name => { @previous_key => { new_key: @key }}) if @previous_key
          result
        end

        if RUBY_ENGINE == 'opal'
          def initialize(key:, data: nil, data_url: nil, url: nil, derivative: nil, derivatives: nil, revision: nil, attributes: nil, composition: nil)
            @key = key.to_s
            @class_name = self.class.name
            @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
            _update_paths
            @_revision = revision ? revision : Redux.fetch_by_path(:data_state, :revision, @class_name, @key)
            @_composition = composition
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
            @_changed_data = {}
            @_changed_data_url = {}
            @_changed_url = {}
          end

          def _load_from_store!
            @_changed_attributes = {}
            @_changed = false
            @_changed_data = {}
            @_changed_data_url = {}
            @_changed_url = {}
          end

          def _update_paths
            @_store_path = [:data_state, @class_name, @key, :attributes]
            @_derivatives_path = [:data_state, @class_name, @key, :derivatives]
          end

          def each(&block)
            attributes.each(&block)
          end

          def [](name)
            _get_attribute(name)
          end

          def []=(name, val)
            _validate_attribute(name, val)
            changed!
            @_changed_attributes[name] = val
          end

          def loaded?
            Redux.fetch_by_path(*@_store_path) ? true : false
          end

          def derivatives
            derivatives = Redux.fetch_by_path(*@_derivatives_path)
            `Object.keys(derivatives)`
          end

          def url(derivative: nil)
            derivative = :default unless derivative
            return @changed_url[derivative] if @changed_url.key?(derivative)
            path = @_derivatives_path + [derivative, :url]
            result = Redux.fetch_by_path(*path)
          end

          def data_url(derivative: nil)
            derivative = :default unless derivative
            return @changed_data_url[derivative] if @changed_data_url.key?(derivative)
            path = @_derivatives_path + [derivative, :data_url]
            result = Redux.fetch_by_path(*path)
          end

          def data(derivative: nil)
            derivative = :default unless derivative
            return @changed_data[derivative] if @changed_data.key?(derivative)
            return @decoded_data[derivative] if @decoded_data.key?(derivative)
            path = @_derivatives_path + [derivative, :data]
            encoded_data = Redux.fetch_by_path(*path)
            @decoded_data[derivative] = Base64.decode64(encoded_data)
          end

          def set(derivative: nil, data: nil, data_url: nil, url: nil)
            unless data || data_url || url
              raise "Either data, data_url or url must be given as keyword argument!"
            end
            changed!
            derivative = :default unless derivative
            @changed_data[derivative][:data] = data if data
            @changed_data[derivative][:data_url] = data_url if data_url
            @changed_data[derivative][:url] = url if url
            nil
          end

          def create
            promise_create
            self
          end

          def promise_create
            data_hash = { instance: to_transport }
            data_hash.deep_merge!(included_items: included_items_to_transport) if respond_to?(:included_items_to_transport)
            class_name = self.class.name
            Isomorfeus::Transport.promise_send_path( 'Isomorfeus::Data::Handler::File', class_name, :create, data_hash).then do |agent|
              if agent.processed
                agent.result
              else
                agent.processed = true
                if agent.response.key?(:error)
                  Isomorfeus.raise_error(message: agent.response[:error])
                end
                data = agent.full_response[:data]
                if data.key?(class_name) && data[class_name].key?(@key) && data[class_name][@key].key?('new_key')
                  @key = data[class_name][@key]['new_key']
                  @revision = data[class_name][@key]['revision'] if data[class_name][@key].key?('revision')
                  _update_paths
                end
                _load_from_store!
                Isomorfeus.store.dispatch(type: 'DATA_LOAD', data: data)
                agent.result = self
              end
            end
          end

          def destroy
            promise_destroy
            nil
          end

          def promise_destroy
            self.class.promise_destroy(@key)
          end

          def reload
            self.class.promise_load!(@key, self)
            self
          end

          def promise_reload
            self.class.promise_load!(@key, self)
          end

          def promise_save
            data_hash = { instance: to_transport }
            data_hash.deep_merge!(included_items: included_items_to_transport) if respond_to?(:included_items_to_transport)
            class_name = self.class.name
            Isomorfeus::Transport.promise_send_path( 'Isomorfeus::Data::Handler::File', class_name, :save, data_hash).then do |agent|
              if agent.processed
                agent.result
              else
                agent.processed = true
                if agent.response.key?(:error)
                  Isomorfeus.raise_error(message: agent.response[:error])
                end
                data = agent.full_response[:data]
                if data.key?(class_name) && data[class_name].key?(@key) && data[class_name][@key].key?('new_key')
                  @key = data[class_name][@key]['new_key']
                  @revision = data[class_name][@key]['revision'] if data[class_name][@key].key?('revision')
                  _update_paths
                end
                _load_from_store!
                Isomorfeus.store.dispatch(type: 'DATA_LOAD', data: data)
                agent.result = self
              end
            end
          end

          # TODO update -> only send partial change
          # included_changed_items
        else # RUBY_ENGINE
          base.instance_exec do
            def instance_from_transport(instance_data, _included_items_data)
              key = instance_data[self.name].keys.first
              revision = instance_data[self.name][key].key?('revision') ? instance_data[self.name][key]['revision'] : nil
              attributes = instance_data[self.name][key].key?('attributes') ? instance_data[self.name][key]['attributes'].transform_keys!(&:to_sym) : nil
              new(key: key, revision: revision, attributes: attributes)
            end
          end

          def initialize(key:, data: nil, data_url: nil, url: nil, derivative: nil, derivatives: nil, revision: nil, attributes: nil, composition: nil)
            @key = key.to_s
            @class_name = self.class.name
            @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
            @_revision = revision
            @_composition = composition
            @_changed = false
            attributes = {} unless attributes
            _validate_attributes(attributes) if attributes
            @_raw_attributes = attributes
            if derivatives
              @_derivatives = derivatives
            else
              derivative = :default unless derivative
              @_derivatives = {}
              @_derivatives[derivative] = { data: data, data_url: data_url, url: url }
            end
            @_changed_derivatives = {}
          end

          def _unchange!
            @_changed = false
            @data = data
            @changed_data = nil
            @data_url = data_url
            @changed_data_url = nil
            @url = url
            @changed_url = nil
          end

          def each(&block)
            @_raw_attributes.each(&block)
          end

          def [](name)
            @_raw_attributes[name]
          end

          def []=(name, val)
            _validate_attribute(name, val)
            changed!
            @_raw_attributes[name] = val
          end

          def loaded?
            true
          end

          def derivatives
            @_derivatives.keys
          end

          def url(derivative: nil)
            derivative = :default unless derivative
            if @_changed_derivatives.key?(derivative) && @_changed_derivatives[derivative].key?(:url)
              return @_changed_derivatives[derivative][:url]
            end
            return @_derivatives[derivative][:url] if @derivatives.key(derivative)
            nil
          end

          def data_url(derivative: nil)
            derivative = :default unless derivative
            if @_changed_derivatives.key?(derivative) && @_changed_derivatives[derivative].key?(:data_url)
              return @_changed_derivatives[derivative][:data_url]
            end
            return @_derivatives[derivative][:data_url] if @derivatives.key(derivative)
            nil
          end

          def data(derivative: nil)
            derivative = :default unless derivative
            if @_changed_derivatives.key?(derivative) && @_changed_derivatives[derivative].key?(:data)
              return @_changed_derivatives[derivative][:data]
            end
            return @_derivatives[derivative][:data] if @derivatives.key(derivative)
            nil
          end

          def set(derivative: nil, data: nil, data_url: nil, url: nil)
            unless data || data_url || url
              raise "Either data, data_url or url must be given as keyword argument!"
            end
            changed!
            derivative = :default unless derivative
            @_changed_derivatives[derivative][:data] = data if data
            @_changed_derivatives[derivative][:data_url] = data_url if data_url
            @_changed_derivatives[derivative][:url] = url if url
            nil
          end

          def create
            previous_key = self.key
            create_block = self.class.instance_variable_get(:@_create_block)
            if create_block
              instance = instance_exec(&create_block)
            else
              store_key = self.class.instance_variable_get(:@default_store)
              file_data = if data
                            data
                          elsif data_url
                            # TODO
                            data_url
                          end
              io_data = StringIO.new(file_data, 'rb')
              uploaded_file = self.class.const_get('Uploader').upload(io_data, store_key, location: key)
              self.key = uploaded_file.id
              self.meta = uploaded_file.metadata
              instance = self
            end
            return nil unless instance
            Isomorfeus.raise_error(message: "#{self.to_s}: execute_create must return self or nil. Returned was: #{instance.class}.") if instance != self
            instance_variable_set(:@previous_key, previous_key) if key != previous_key
            _unchange!
            self
          end

          def promise_create
            promise = Promise.new
            promise.resolve(create)
          end

          def save
            previous_key = self.key
            save_block = self.class.instance_variable_get(:@_save_block)
            if save_block
              instance = instance_exec(&self.class.instance_variable_get(:@_save_block))
            else
              store_key = self.class.instance_variable_get(:@default_store)
              file_data = if data
                            data
                          elsif data_url
                            # TODO
                            data_url
                          end
              io_data = StringIO.new(file_data, 'rb')
              uploaded_file = self.class.const_get('Uploader').upload(io_data, store_key, location: key)
              self.key = uploaded_file.id
              self.meta = uploaded_file.metadata
              instance = self
            end
            return nil unless instance
            Isomorfeus.raise_error(message: "#{self.to_s}: execute_save must return self or nil. Returned was: #{instance.class}.") if instance != self
            instance_variable_set(:@previous_key, previous_key) if key != previous_key
            _unchange!
            self
          end

          def promise_save
            promise = Promise.new
            promise.resolve(save)
          end

          def image_attacher
            # TODO
          end
        end # RUBY_ENGINE

        def current_user
          Isomorfeus.current_user
        end

        def pub_sub_client
          Isomorfeus.pub_sub_client
        end
      end
    end
  end
end
