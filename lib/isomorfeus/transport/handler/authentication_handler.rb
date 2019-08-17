module Isomorfeus
  module Transport
    module Handler
      class AuthenticationHandler < LucidHandler::Base
        TIMEOUT = 30
        attr_reader env

        on_request do |pub_sub_client, current_user, request, _response|
          result = { error: 'Authentication failed' }
          # promise_send_path('Isomorfeus::Transport::Handler::AuthenticationHandler', 'login', user_identifier, user_password_bcrypt)
          request.each_key do |login_or_logout|
            if login_or_logout == 'login'
              tries = pub_sub_client.instance_variable_get(:@isomorfeus_authentication_tries)
              tries = 0 unless tries
              tries += 1
              sleep(5) if tries > 3
              pub_sub_client.instance_variable_set(:@isomorfeus_authentication_tries, tries)
              request['login'].each_key do |user_identifier|
                user = nil
                Isomorfeus.valid_user_classes.each do |user_class|
                  promise = user_class.promise_login(user_identifier, request[user_identifier])
                  unless promise.realized?
                    start = Time.now
                    until promise.realized?
                      break if (Time.now - start) > TIMEOUT
                      sleep 0.01
                    end
                  end
                  user = promise.value
                  break if user
                end
                if user
                  pub_sub_client.instance_variable_set(:@isomorfeus_user, user)
                  pub_sub_client.instance_variable_set(:@isomorfeus_authentication_tries, nil)
                  result = { success: 'ok', data: user.to_transport }
                end
              end
            elsif login_or_logout == 'logout'
              begin
                promise = current_user.promise_logout
                unless promise.realized?
                  start = Time.now
                  until promise.realized?
                    break if (Time.now - start) > TIMEOUT
                    sleep 0.01
                  end
                end
              ensure
                pub_sub_client.instance_variable_set(:@isomorfeus_user, nil)
                result = { success: 'ok' }
              end
            end
          end
          result
        end
      end
    end
  end
end