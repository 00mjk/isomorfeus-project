module Isomorfeus
  module Data
    module Handler
      class GraphLoadHandler < LucidHandler::Base
        on_request do |pub_sub_client, session_id, current_user, request, response|
          result = { error: 'No such thing' }
          # promise_send_path('Isomorfeus::Data::Handler::GraphLoadHandler', self.to_s, props_hash)
          request.each_key do |graph_class_name|
            if Isomorfeus.valid_graph_class_name?(graph_class_name)
              graph_class = Isomorfeus.cached_graph_class(graph_class_name)
              if graph_class
                props_json = request[graph_class_name]
                begin
                  props = Oj.load(props_json, mode: :strict)
                  props.merge!({pub_sub_client: pub_sub_client, session_id: session_id, current_user: current_user})
                  graph = graph_class.load(props)
                  graph.instance_exec do
                    graph_class.on_load_block.call(pub_sub_client, session_id, current_user) if graph_class.on_load_block
                  end
                  response.deep_merge!(data: graph.to_transport)
                  response.deep_merge!(data: graph.included_items_to_transport)
                  result = { success: 'ok' }
                rescue Exception => e
                  result = if Isomorfeus.production?
                             { error: { graph_class_name => 'No such thing!' }}
                           else
                             { error: { graph_class_name => "Isomorfeus::Data::Handler::GraphLoadHandler: #{e.message}" }}
                           end
                end
              else
                result = { error: { graph_class_name => 'No such thing!' }}
              end
            else
              result = { error: { graph_class_name => 'No such thing!' }}
            end
          end
          result
        end
      end
    end
  end
end
