module Isomorfeus
  module Data
    module Reducer
      def self.add_reducer_to_store
        data_reducer = Redux.create_reducer do |prev_state, action|
          action_type = action[:type]
          if action_type.JS.startsWith('DATA_')
            case action_type
            when 'DATA_STATE'
              if action.key?(:set_state)
                action[:set_state]
              else
                prev_state
              end
            when 'DATA_LOAD'
              prev_state.deep_merge(action[:data])
            else
              prev_state
            end
          else
            prev_state.nil? ? {} : prev_state
          end
        end

        Redux::Store.preloaded_state_merge!(data_state: {})
        Redux::Store.add_reducer(data_state: data_reducer)
      end
    end
  end
end
