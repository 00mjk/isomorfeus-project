module Isomorfeus
  module Transport
    def self.promise_send(request)
      agent = Isomorfeus::Transport::RequestAgent.new
      Isomorfeus.client_transport_driver.send_request('request' => { agent.id => request })
      agent.promise
    end
  end
end