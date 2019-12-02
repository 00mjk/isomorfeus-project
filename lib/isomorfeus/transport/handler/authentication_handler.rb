module Isomorfeus
  module Transport
    module Handler
      class AuthenticationHandler < LucidHandler::Base
        TIMEOUT = 30

        on_request do |pub_sub_client, current_user, response_agent|
          result = { error: 'Authentication failed' }
          # promise_send_path('Isomorfeus::Transport::Handler::AuthenticationHandler', 'login', user_class_name, user_identifier, user_password)
          response_agent.request.each_key do |login_or_logout|
            if login_or_logout == 'login'
              tries = pub_sub_client.instance_variable_get(:@isomorfeus_authentication_tries)
              tries = 0 unless tries
              tries += 1
              sleep(5) if tries > 3 # TODO, this needs a better solution (store data in user/session)
              pub_sub_client.instance_variable_set(:@isomorfeus_authentication_tries, tries)
              response_agent.request['login'].each_key do |user_class_name|
                user = nil
                if Isomorfeus.valid_user_class_name?(user_class_name)
                  user_class = Isomorfeus.cached_user_class(user_class_name)
                  response_agent.request['login'][user_class_name].each_key do |user_identifier|
                    promise = user_class.promise_login(user_identifier, response_agent.request['login'][user_class_name][user_identifier])
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
                end
                if user
                  pub_sub_client.instance_variable_set(:@isomorfeus_user, user)
                  pub_sub_client.instance_variable_set(:@isomorfeus_authentication_tries, nil)
                  # TODO store session in db and supply session cookie: session_cookie: uuid or so
                  response_agent.agent_result = { success: 'ok', data: user.to_transport }
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
                response_agent.agent_result = { success: 'ok' }
              end
            end
          end
        end
      end
    end
  end
end
