module Isomorfeus
  module Transport
    class RequestAgent
      def self.agents
        @_agents ||= {}
      end

      def self.get(object_id)
        agents[object_id]
      end

      def self.get!(object_id)
        agents.delete(object_id.to_s)
      end

      attr_reader :id
      attr_reader :promise
      attr_reader :request

      def initialize(request = nil)
        @id = object_id.to_s
        self.class.agents[@id] = self
        @promise = Promise.new
        @request = request
      end
    end
  end
end