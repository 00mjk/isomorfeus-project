module LucidAuthentication
  module Mixin
    if RUBY_ENGINE == 'opal'
      def self.included(base)

        base.instance_exec do
          def authentication(&block)
          end

          def promise_login(user_identifier, user_password, scheme = :isomorfeus)
              send("promise_authentication_with_#{scheme}", user_identifier, user_password)
          end

          def promise_authentication_with_isomorfeus(user_identifier, user_password)
            if Isomorfeus.production?
              Isomorfeus.raise_error(message: "Connection not secure, can't login") unless Isomorfeus::Transport.socket.url.start_with?('wss:')
            else
              `console.warn("Connection not secure, ensure a secure connection in production, otherwise login will fail!")` unless Isomorfeus::Transport.socket.url.start_with?('wss:')
            end
            Isomorfeus::Transport.promise_send_path('Isomorfeus::Transport::Handler::AuthenticationHandler', 'login', self.name, user_identifier, user_password).then do |agent|
              if agent.processed
                agent.result
              else
                agent.processed = true
                if agent.response.key?(:success)
                  Isomorfeus.store.dispatch(type: 'DATA_LOAD', data: agent.response[:data])
                  class_name = agent.response[:data].keys.first
                  key = agent.response[:data][class_name].keys.first

                  # TODO set session cookie
                  # agent.response[:session_cookie]
                  agent.result = Isomorfeus.cached_data_class(class_name).new(key: key)
                else
                  error = agent.response[:error]
                  `console.err(error)` if error
                  Isomorfeus.raise_error(message: 'Login failed!') # triggers .fail
                end
              end
            end
          end
        end
      end

      def promise_logout(scheme = :isomorfeus)
        send("promise_deauthentication_with_#{scheme}")
      end

      def promise_deauthentication_with_isomorfeus
        Isomorfeus::Transport.promise_send_path('Isomorfeus::Transport::Handler::AuthenticationHandler', 'logout', 'logout').then do |agent|
          agent.processed = true
          agent.response.key?(:success) ? true : raise('Logout failed!')
        end
      end
    else
      def self.included(base)
        Isomorfeus.add_valid_user_class(base)

        base.instance_exec do
          def authentication(&block)
            @authentication_block = block
          end

          def promise_login(user_identifier, user_password_or_token, scheme = :isomorfeus)
            send("promise_authentication_with_#{scheme}", user_identifier, user_password_or_token)
          end

          def promise_authentication_with_isomorfeus(user_identifier, user_password_or_token)
            promise_or_user = @authentication_block.call(user_identifier, user_password_or_token)
            if promise_or_user.class == Promise
              promise_or_user
            else
              Promise.new.resolve(promise_or_user)
            end
          end
        end
      end

      def promise_logout(scheme = :isomorfeus)
        send("promise_deauthentication_with_#{scheme}")
      end

      def promise_deauthentication_with_isomorfeus
        Promise.new.resolve(true)
      end
    end
  end
end
