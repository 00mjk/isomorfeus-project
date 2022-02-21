module Isomorfeus
  module Transport
    class RequestAgent
      class << self
        def agents
          @_agents ||= {}
        end

        def get(object_id)
          agents[object_id]
        end

        def del!(object_id)
          agents.delete(object_id.to_s)
        end
      end

      attr_accessor :processed
      attr_accessor :result
      attr_accessor :response
      attr_accessor :full_response
      attr_accessor :sent
      attr_reader :id
      attr_reader :promise
      attr_reader :request

      def initialize(request = nil)
        @id = object_id.to_s
        self.class.agents[@id] = self
        current_agent = self
        @promise = Promise.new
        @promise.then do
                        Isomorfeus::Transport.unregister_request_in_progress(current_agent.id)
                        Isomorfeus::Transport::RequestAgent.del!(current_agent.id)
                      end
        @promise.fail do |e|
                        STDERR.puts "#{e}"
                        Isomorfeus::Transport.unregister_request_in_progress(current_agent.id)
                        Isomorfeus::Transport::RequestAgent.del!(current_agent.id)
                      end
        @request = request
        @sent = false
      end

      def process(&block)
        return self.result if self.processed
        self.processed = true
        Isomorfeus.raise_error(message: self.response[:error]) if self.response.key?(:error)
        self.result = block.call(self)
        @promise.resolve(self) unless @promise.realized?
        self.result
      end
    end
  end
end
