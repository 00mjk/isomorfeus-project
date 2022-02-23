module Isomorfeus
  module Transport
    class SsrLogin
      def self.init
        session_id = `global.IsomorfeusSessionId`
        if session_id && session_id.size > 0
          Isomorfeus::Transport.promise_send_path('Isomorfeus::Transport::Handler::AuthenticationHandler', 'ssr_login', session_id).then do |agent|
            if agent.processed
              agent.result
            else
              agent.processed = true
              if agent.response.key?(:success)
                Isomorfeus.store.dispatch(type: 'DATA_LOAD', data: agent.response[:data])
                class_name = agent.response[:data].keys.first
                key = agent.response[:data][class_name].keys.first
                logged_in_user = Isomorfeus.cached_data_class(class_name).new(key: key)
                Isomorfeus.set_current_user(logged_in_user)
              else
                error = agent.response[:error]
                Isomorfeus.raise_error(message: "SSR Login failed, #{error}!") # triggers .fail
              end
            end
          end
        end
      end
    end
  end
end

Isomorfeus.add_transport_init_class_name('Isomorfeus::Transport::SsrLogin')
