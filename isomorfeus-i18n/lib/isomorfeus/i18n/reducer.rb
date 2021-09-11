module Isomorfeus
  module I18n
    module Reducer
      def self.add_reducer_to_store
        i18n_reducer = Redux.create_reducer do |prev_state, action|
          action_type = action[:type]
          if action_type.JS.startsWith('I18N_')
            case action_type
            when 'I18N_STATE'
              if action.key?(:set_state)
                action[:set_state]
              else
                prev_state
              end
            when 'I18N_LOAD'
              new_state = {}.merge!(prev_state)
              if action.key?(:collected)
                action[:collected].each do |act|
                  new_state.deep_merge!(act[:data])
                end
              else
                new_state.deep_merge!(action[:data])
              end
              new_state
            else
              prev_state
            end
          else
            prev_state
          end
        end

        Redux::Store.preloaded_state_merge!(i18n_state: {})
        Redux::Store.add_reducer(i18n_state: i18n_reducer)
      end
    end
  end
end
