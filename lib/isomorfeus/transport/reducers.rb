module Isomorfeus
  module Transport
    module Reducers
      def self.add_reducers_to_store

        # the fetch reducer just keeps record of all fetches or stores
        # the real work is done be the store middleware
        # when a request is fulfilled, its removed from the list
        transport_reducer = Redux.create_reducer do |prev_state, action|
          case action[:type]
          when 'TRANSPORT_REQUEST'
            new_state = {}.merge!(prev_state)
            unless new_state[:request_count]
              new_state[:request_count] = 0
              new_state[:requests] = {}
            end
            new_state[:request_count] = new_state[:request_count] + 1
            new_state[:requests].merge!(action[:request])
            new_state
          when 'TRANSPORT_RESPONSE'
            new_state = {}.merge!(prev_state)
            new_state[:request_count] = new_state[:request_count] - 1
            new_state[:requests].delete!(action[:response].keys.first)
          else
            prev_state
          end
        end

        Redux::Store.add_reducer(transport_state: transport_reducer)
      end
    end
  end
end
