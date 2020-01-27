module Isomorfeus
  module Data
    module GenericInstanceApi
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

      if RUBY_ENGINE == 'opal'
        def loaded?
          Redux.fetch_by_path(*@_store_path) ? true : false
        end

        def destroy
          promise_destroy
          nil
        end

        def promise_destroy
          self.class.promise_destroy(@key)
        end

        def reload
          self.class.promise_load(@key, self)
          self
        end

        def promise_reload
          self.class.promise_load(@key, self)
        end

        def save
          promise_save
          self
        end
        alias create save

        def promise_save
          data_hash = { instance: to_transport }
          data_hash.deep_merge!(included_items: included_items_to_transport) if respond_to?(:included_items_to_transport)
          Isomorfeus::Transport.promise_send_path( 'Isomorfeus::Data::Handler::Generic', self.name, :save, data_hash).then do |agent|
            if agent.processed
              agent.result
            else
              agent.processed = true
              if agent.response.key?(:error)
                `console.error(#{agent.response[:error].to_n})`
                Isomorfeus.raise_error(message: agent.response[:error])
              end
              data = agent.full_response[:data]
              if data.key?(self.name) && data[self.name].key?(@key) && data[self.name][@key].key?('new_key')
                @key = data[self.name][@key]['new_key']
                @revision = data[self.name][@key]['revision'] if data[self.name][@key].key?('revision')
                _update_paths
              end
              Isomorfeus.store.dispatch(type: 'DATA_LOAD', data: data)
              agent.result = true
            end
          end
        end
        alias promise_create promise_save

        # TODO update -> only send partial change
        # included_changed_items
      else # RUBY_ENGINE
        def loaded?
          true
        end
      end # RUBY_ENGINE

      def save
        self.class.save(instance: self)
        self
      end

      def promise_save
        promise = Promise.new
        promise.resolve(save)
      end

      def current_user
        Isomorfeus.current_user
      end

      def pub_sub_client
        Isomorfeus.pub_sub_client
      end
    end
  end
end
