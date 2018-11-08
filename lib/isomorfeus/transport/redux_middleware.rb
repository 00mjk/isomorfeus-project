module Isomorfeus
  module Transport
    module ReduxMiddleware
      # TODO this is the place where we can accumulate and delay requests
      # TODO agent.id below!
      def self.add_middleware_to_store
        middleware = nil
        %x{
          middleware = function(store) {
            return function(next) {
              return function(action) {
                if (!action.type.startsWith("TRANSPORT_")) { return next(action); }
                switch (action.type) {
                  case "TRANSPORT_REQUEST":
                    #{Isomorfeus::Transport.promise_send(`Opal.Hash.$new(action.request)`)}
                    return next(action);
                  case "TRANSPORT_RESPONSE":
                    var agent = #{Isomorfeus::Transport::RequestAgent.get!(`action.response.agent_id`)};
                    agent.$promise.$resolve(action.response.data);
                    return next(action);
                  case "TRANSPORT_NOTIFICATION":
                    store.dispatch(action.notification);
                    return next(action);
                  default:
                    return next(action);
                }
              }
            }
          }
        }

        Redux::Store.add_middleware(middleware)
      end
    end
  end
end