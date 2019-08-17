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
            user_password_bcrypt = `Opal.global.BCryptJS.hashSync(user_password);`
            promise_send_path('Isomorfeus::Transport::Handler::AuthenticationHandler', 'login', user_identifier, user_password_bcrypt).then do |response|
              if response[:agent_response].key?(:success)
                Isomorfeus.store.dispatch(type: 'DATA_LOAD', data: response[:agent_response][:data])
                class_name = response[:agent_response][:data][:nodes].keys.first
                node_id = response[:agent_response][:data][:nodes][class_name].keys.first
                Isomorfeus.cached_node_class(class_name).new({id: node_id})
              else
                raise 'Login failed!' # calls .fail
              end
            end
          end
        end
      end

      def promise_logout(scheme = :isomorfeus)
        send("promise_deauthentication_with_#{scheme}")
      end

      def promise_deauthentication_with_isomorfeus
        promise_send_path('Isomorfeus::Transport::Handler::AuthenticationHandler', 'logout', 'logout').then do |response|
          response[:agent_response].key?(:success) ? true : raise 'Logout failed!'
        end
      end
    else
      def self.included(base)
        Isomorfeus.add_valid_user_class(base)

        base.instance_exec do
          def authentication(&block)
            @authentication_block = block
          end

          def promise_login(user_identifier, user_password_bcrypt_or_token, scheme = :isomorfeus)
            send("promise_authentication_with_#{scheme}", user_identifier, user_password_bcrypt_or_token)
          end

          def promise_authentication_with_isomorfeus(user_identifier, user_password_bcrypt_or_token)
            promise_or_user = @authentication_block.call(user_identifier, user_password_bcrypt_or_token)
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
