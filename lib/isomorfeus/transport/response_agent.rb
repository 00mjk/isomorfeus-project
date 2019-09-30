module Isomorfeus
  module Transport
    class ResponseAgent
      attr_reader :agent_id
      attr_reader :request
      attr_accessor :agent_result
      attr_accessor :outer_result
      attr_accessor :error

      def initialize(agent_id, request)
        @agent_id = agent_id
        @request = request
      end

      def result
        return { response: { agent_ids: { @agent_id => @error }}} if @error
        response = { response: { agent_ids: { @agent_id => @agent_result }}}
        response.deep_merge!(@outer_result) if @outer_result
        return response
      end
    end
  end
end
