module Isomorfeus
  module Data
    module GenericInstanceApi
      def to_cid
        [@class_name, @key]
      end

      if RUBY_ENGINE == 'opal'
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

        def store
          promise_store
          self
        end
        alias create store

        def promise_store
          Isomorfeus::Transport.promise_send_path( 'Isomorfeus::Data::Handler::GenericHandler', _handler_type, self.name, 'store', to_transport).then do |agent|
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
        alias promise_create promise_store

        def loaded?
          @_loaded ||= (Redux.fetch_by_path(*@_store_path) ? true : false)
        end
      else
        def loaded?
          @_loaded
        end
      end
    end
  end
end
