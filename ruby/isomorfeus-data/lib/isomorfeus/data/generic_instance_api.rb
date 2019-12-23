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

        def promise_load_once
          self.class.promise_load_once(key: key, instance: self)
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
          data_hash = to_transport
          if self.respond_to?(:included_changed_items)
            data_hash.deep_merge!(self.included_changed_items)
          end
          Isomorfeus::Transport.promise_send_path( 'Isomorfeus::Data::Handler::Generic', self.name, 'save', data_hash).then do |agent|
            if agent.processed
              agent.result
            else
              agent.processed = true
              if agent.response.key?(:error)
                `console.error(#{agent.response[:error].to_n})`
                raise agent.response[:error]
              end
              Isomorfeus.store.dispatch(type: 'DATA_LOAD', data: agent.full_response[:data])
              agent.result = true
            end
          end
        end
        alias promise_create promise_save
      else # RUBY_ENGINE
        def loaded?
          true
        end
      end # RUBY_ENGINE
    end
  end
end
