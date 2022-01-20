module Isomorfeus
  module Transport
    module Handler
      class AuthenticationHandler < LucidHandler::Base
        TIMEOUT = 30

        on_request do |response_agent|
          # promise_send_path('Isomorfeus::Transport::Handler::AuthenticationHandler', 'login', user_class_name, user_identifier, user_password)
          response_agent.request.each_key do |login_or_ssr_login|
            if login_or_ssr_login == 'login'
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
                  user_identifier = response_agent.request['login'][user_class_name].keys.first
                  promise = user_class.promise_login(user: user_identifier, pass: response_agent.request['login'][user_class_name][user_identifier])
                  unless promise.realized?
                    start = Time.now
                    until promise.realized?
                      break if (Time.now - start) > TIMEOUT
                      sleep 0.01
                    end
                  end
                  user = promise.value
                end
                if user
                  session_id = SecureRandom.uuid
                  session_cookie = "session=#{session_id}; SameSite=Strict; HttpOnly; Path=/; Max-Age=2592000#{'; Secure' if Isomorfeus.production?}"
                  session_cookie_accessor = SecureRandom.uuid
                  Isomorfeus.pub_sub_client.instance_variable_set(:@isomorfeus_authentication_tries, nil)
                  Isomorfeus.session_store.add(session_id: session_id, cookie: session_cookie, user: user, accessor: session_cookie_accessor)
                  response_agent.agent_result = { success: 'ok', data: user.to_transport, session_cookie_accessor: session_cookie_accessor }
                end
              end
            elsif login_or_ssr_login == 'ssr_login'
              response_agent.agent_result = { error: 'Authentication failed' }
              session_id = response_agent.request['ssr_login']
              user = Isomorfeus.session_store.get_user(session_id: session_id)
              if user
                Isomorfeus.pub_sub_client.instance_variable_set(:@isomorfeus_authentication_tries, nil)
                response_agent.agent_result = { success: 'ok', data: user.to_transport }
              end
            end
          end
        end
      end
    end
  end
end
