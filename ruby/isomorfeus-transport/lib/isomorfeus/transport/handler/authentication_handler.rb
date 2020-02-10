module Isomorfeus
  module Transport
    module Handler
      class AuthenticationHandler < LucidHandler::Base
        TIMEOUT = 30

        on_request do |response_agent|
          # promise_send_path('Isomorfeus::Transport::Handler::AuthenticationHandler', 'login', user_class_name, user_identifier, user_password)
          response_agent.request.each_key do |login_or_logout|
            if login_or_logout == 'login'
              response_agent.agent_result = { error: 'Authentication failed' }
              tries = pub_sub_client.instance_variable_get(:@isomorfeus_authentication_tries)
              tries = 0 unless tries
              tries += 1
              sleep(5) if tries > 3 # TODO, this needs a better solution (store data in user/session)
              Isomorfeus.pub_sub_client.instance_variable_set(:@isomorfeus_authentication_tries, tries)
              response_agent.request['login'].each_key do |user_class_name|
                user = nil
                if Isomorfeus.valid_user_class_name?(user_class_name)
                  user_class = Isomorfeus.cached_user_class(user_class_name)
                  response_agent.request['login'][user_class_name].each_key do |user_identifier|
                    promise = user_class.promise_login(user: user_identifier, pass: response_agent.request['login'][user_class_name][user_identifier])
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
                  session_cookie = "session=#{SecureRandom.uuid};max-age=2592000"
                  Isomorfeus.pub_sub_client.instance_variable_set(:@isomorfeus_user, user)
                  Isomorfeus.pub_sub_client.instance_variable_set(:@isomorfeus_authentication_tries, nil)
                  Isomorfeus.pub_sub_client.instance_variable_set(:@isomorfeus_session_cookie, session_cookie)
                  Isomorfeus.session_store.add(cookie: session_cookie, user: user)
                  response_agent.agent_result = { success: 'ok', data: user.to_transport, session_cookie: session_cookie }
                end
              end
            elsif login_or_logout == 'logout'
              begin
                # bogus
                session_cookie = nil
              ensure
                Isomorfeus.pub_sub_client.instance_variable_set(:@isomorfeus_user, nil)
                Isomorfeus.pub_sub_client.instance_variable_set(:@isomorfeus_authentication_tries, nil)
                Isomorfeus.pub_sub_client.instance_variable_set(:@isomorfeus_session_cookie, nil)
                Isomorfeus.session_store.remove(cookie: session_cookie)
                response_agent.agent_result = { success: 'ok' }
              end
            end
          end
        end
      end
    end
  end
end
