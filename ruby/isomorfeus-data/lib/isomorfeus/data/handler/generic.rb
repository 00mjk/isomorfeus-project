# frozen_string_literal: true

module Isomorfeus
  module Data
    module Handler
      class Generic < LucidHandler::Base
        # responsible for loading:
        # LucidData::Array
        # LucidData::Hash
        # LucidData::Edge
        # LucidData::Document
        # LucidData::Collection
        # LucidData::EdgeCollection
        # LucidData::Graph
        # LucidData::Composition

        def process_request(pub_sub_client, current_user, response_agent)
          # promise_send_path('Isomorfeus::Data::Handler::Generic', self.to_s, action, props_hash)
          response_agent.request.each_key do |type_class_name|
            if Isomorfeus.valid_data_class_name?(type_class_name)
              type_class = Isomorfeus.cached_data_class(type_class_name)
              if type_class
                response_agent.request[type_class_name].each_key do |action|
                  case action
                  when 'load' then process_load(pub_sub_client, current_user, response_agent, type_class, type_class_name)
                  when 'query' then process_query(pub_sub_client, current_user, response_agent, type_class, type_class_name)
                  when 'save' then process_save(pub_sub_client, current_user, response_agent, type_class, type_class_name)
                  when 'destroy' then process_destroy(pub_sub_client, current_user, response_agent, type_class, type_class_name)
                  else response_agent.error = { error: { action => 'No such thing!' }}
                  end
                end
              else response_agent.error = { error: { type_class_name => 'No such thing!' }}
              end
            else response_agent.error = { error: { type_class_name => 'No such thing!' }}
            end
          end
        rescue Exception => e
          response_agent.error = if Isomorfeus.production? then { error: 'No such thing!' }
                                 else { error: "Isomorfeus::Data::Handler::Generic: #{e.message}\n#{e.backtrace.join("\n")}" }
                                 end
        end

        def process_load(pub_sub_client, current_user, response_agent, type_class, type_class_name)
          props = response_agent.request[type_class_name]['load']
          props.transform_keys!(&:to_sym)
          props.merge!(pub_sub_client: pub_sub_client, current_user: current_user)
          if current_user.authorized?(type_class, :load, props)
            loaded_type = type_class.load(**props)
            if loaded_type
              response_agent.outer_result = { data: loaded_type.to_transport }
              if loaded_type.respond_to?(:included_items_to_transport)
                response_agent.outer_result.deep_merge!(data: loaded_type.included_items_to_transport)
              end
              response_agent.agent_result = { success: 'ok' }
            else response_agent.error = { error: { type_class_name => 'No such thing!' }}
            end
          else response_agent.error = { error: 'Access denied!' }
          end
        end

        def process_query(pub_sub_client, current_user, response_agent, type_class, type_class_name)
          props_json = response_agent.request[type_class_name]['query']
          props = Oj.load(props_json, mode: :strict)
          props.transform_keys!(&:to_sym)
          props[:props].transform_keys!(&:to_sym)
          props.deep_merge!({ pub_sub_client: pub_sub_client, current_user: current_user })
          if current_user.authorized?(type_class, :query, props[:props])
            queried_type = type_class.query(**props)
            if queried_type
              response_agent.outer_result = { data: queried_type.to_transport }
              if queried_type.respond_to?(:included_items_to_transport)
                response_agent.outer_result.deep_merge!(data: queried_type.included_items_to_transport)
              end
              response_agent.agent_result = { success: 'ok' }
            else response_agent.error = { error: { type_class_name => 'No such thing!' }}
            end
          else response_agent.error = { error: 'Access denied!' }
          end
        end

        def process_save(pub_sub_client, current_user, response_agent, type_class, type_class_name)
          data_hash_json = response_agent.request[type_class_name]['save']
          data_hash = Oj.load(data_hash_json, mode: :strict)
          response_agent.outer_result = {}
          if current_user.authorized?(type_class, :save, { pub_sub_client: pub_sub_client, current_user: current_user })
            data_hash.each_key do |data_class_name|
              data_hash[data_class_name].each_key do |key|
                if Isomorfeus.valid_data_class_name?(type_class_name)
                  data_class = Isomorfeus.cached_data_class(data_class_name)
                  if data_class
                    item_data_hash = data_hash[data_class_name][key]
                    item_data_hash = item_data_hash.merge({ pub_sub_client: pub_sub_client, current_user: current_user })
                    if current_user.authorized?(data_class, :save, item_data_hash)
                      saved_type = data_class.save(**item_data_hash)
                      if saved_type
                        response_agent.outer_result.deep_merge!({ data: saved_type.to_transport })
                      end
                    else
                      response_agent.error = { error: 'Access denied!' }
                      break
                    end
                  else
                    response_agent.error = { error: 'Access denied!' }
                    break
                  end
                end
              end
            end
            response_agent.agent_result = { success: 'ok' }
          else response_agent.error = { error: 'Access denied!' }
          end
        end

        def process_destroy(pub_sub_client, current_user, response_agent, type_class, type_class_name)
          props_json = response_agent.request[type_class_name]['destroy']
          props = Oj.load(props_json, mode: :strict)
          props.merge!(pub_sub_client: pub_sub_client, current_user: current_user)
          if current_user.authorized?(type_class, :destroy, props)
            destroyed_type = type_class.destroy(**props)
            if destroyed_type
              response_agent.outer_result = { data: destroyed_type }
              response_agent.agent_result = { success: 'ok' }
            else response_agent.error = { error: { type_class_name => 'No such thing!' }}
            end
          else response_agent.error = { error: 'Access denied!' }
          end
        end
      end
    end
  end
end
