module LucidAuthentication
  module Mixin
    def anonymous?
      self.class == Anonymous
    end

    if RUBY_ENGINE == 'opal'
      def self.included(base)
        base.instance_exec do
          def execute_login(&block)
          end

          def promise_login(user: nil, pass: nil, scheme: :isomorfeus)
              send("promise_authentication_with_#{scheme}",user: user, pass: pass)
          end

          def promise_authentication_with_isomorfeus(user: nil, pass: nil)
            if Isomorfeus.production?
              Isomorfeus.raise_error(message: "Connection not secure, can't login") unless Isomorfeus::Transport.socket.url.start_with?('wss:')
            else
              `console.warn("Connection not secure, ensure a secure connection in production, otherwise login will fail!")` unless Isomorfeus::Transport.socket.url.start_with?('wss:')
            end
            Isomorfeus::Transport.promise_send_path('Isomorfeus::Transport::Handler::AuthenticationHandler', 'login', self.name, user, pass).then do |agent|
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
                  logged_in_user = Isomorfeus.cached_data_class(class_name).new(key: key)
                  Isomorfeus.set_current_user(logged_in_user)
                  agent.result = logged_in_user
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

      def promise_logout(scheme: :isomorfeus)
        send("promise_deauthentication_with_#{scheme}")
      end

      def promise_deauthentication_with_isomorfeus
        Isomorfeus::Transport.promise_send_path('Isomorfeus::Transport::Handler::AuthenticationHandler', 'logout', 'logout').then do |agent|
          # TODO unset session cookie
          # agent.response[:session_cookie]
          Isomorfeus.set_current_user(nil)
          agent.processed = true
          agent.response.key?(:success) ? true : raise('Logout failed!')
        end
      end
    else
      def self.included(base)
        Isomorfeus.add_valid_user_class(base)

        base.instance_exec do
          def execute_login(&block)
            @execute_login_block = block
          end

          def promise_login(user: nil, pass: nil, scheme: :isomorfeus)
            send("promise_authentication_with_#{scheme}", user: user, pass: pass)
          end

          def promise_authentication_with_isomorfeus(user: nil, pass: nil)
            promise_or_user = @execute_login_block.call(user: user, pass: pass)
            if promise_or_user.class == Promise
              promise_or_user
            else
              Promise.new.resolve(promise_or_user)
            end
          end
        end
      end

      def encrypt_password(password, password_confirmation)
        raise "Password and confirmation don't match!" unless password == password_confirmation
        BCrypt::Password.create(password).to_s
      end

      def passwords_match?(encrypted_password, given_password)
        bcrypt_pass = BCrypt::Password.new(encrypted_password)
        bcrypt_pass == given_password
      end

      def promise_logout(scheme: :isomorfeus)
        send("promise_deauthentication_with_#{scheme}")
      end

      def promise_deauthentication_with_isomorfeus
        Promise.new.resolve(true)
      end
    end
  end
end
