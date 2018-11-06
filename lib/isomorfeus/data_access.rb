module Isomorfeus
  module DataAccess
    def self.local_fetch(*path)
      # get active redux component
      # (There should be a better way to get the component)
      active_component = `Opal.React.active_redux_component()`

      if active_component
        # try to get data from component state or props or store
        start_data = active_component.JS.data_access.JS[:record_state]
        if start_data
          final_data = `path.reduce(function(prev, curr) { prev && prev[curr] }, current_state)`
          # if final data doesn't exist, its set to 'null', so nil or false are ok as final_data
          return final_data if final_data != `null`
        end
      else
        # try to get data from store
        start_data = Isomorfeus.store.get_state[path[0]]
        if start_data
          final_data = `path.reduce(function(prev, curr) { prev && prev[curr] }, current_state)`
          # if final data doesn't exist, its set to 'null', so nil or false are ok as final_data
          return final_data if final_data != `null`
        end
      end
      `null`
    end

    def self.promise_fetch(*path)
      request = path.inject({}) do |memo, key|
        memo[key] = {}
      end

      agent = Isomorfeus::Transport::RequestAgent.new
      Isomorfeus.store.dispatch(type: 'TRANSPORT_REQUEST', request: request.merge!(agent_id: agent.id))
      agent.promise
    end

    def self.promise_store(*path, value)
      request = path.inject({}) do |memo, key|
        if key == path.last
          memo[key] = value
        else
          if memo.has_key?(key)
            memo[key]
          else
            memo[key] = {}
          end
        end
      end

      agent = Isomorfeus::Transport::RequestAgent.new
      Isomorfeus.store.dispatch(type: 'TRANSPORT_REQUEST', request: request.merge!(agent_id: agent.id))
      agent.promise
    end

    def self.register_used_store_path(*path)
      active_component = `Opal.React.active_redux_component()`
      active_component.JS.register_used_store_path(path) if active_component
    end
  end
end
