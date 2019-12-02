# frozen_string_literal: true

module Isomorfeus
  module Data
    module Handler
      class Generic < LucidHandler::Base
        # responsible for loading:
        # LucidArray
        # LucidHash
        # LucidData::Edge
        # LucidData::Document
        # LucidData::Collection

        def process_request(pub_sub_client, current_user, response_agent)
          # promise_send_path('Isomorfeus::Data::Handler::Generic', self.to_s, action, props_hash)
          response_agent.request.each_key do |type_class_name|
            if Isomorfeus.valid_data_class_name?(type_class_name)
              type_class = Isomorfeus.cached_data_class(type_class_name)
              if type_class
                response_agent.request[type_class_name].each_key do |action|
                  case action
                  when 'load' then process_load(pub_sub_client, current_user, response_agent, type_class, type_class_name, action)
                  when 'store' then process_store(pub_sub_client, current_user, response_agent, type_class, type_class_name, action)
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

        def process_load(pub_sub_client, current_user, response_agent, type_class, type_class_name, action)
          props = response_agent.request[type_class_name][action]
          # STDERR.puts "PROPS_JSON #{props_json}"
          # props = Oj.load(props_json, mode: :strict)
          props.transform_keys!(&:to_sym)
          props.merge!(pub_sub_client: pub_sub_client, current_user: current_user)
          if current_user.authorized?(type_class, :load, props)
            loaded_type = type_class.load(**props)
            if loaded_type
              on_load_block = type_class.instance_variable_get(:@_on_load_block)
              loaded_type.instance_exec(pub_sub_client, current_user, &on_load_block) if on_load_block
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

        def process_store(pub_sub_client, current_user, response_agent, type_class, type_class_name, action)
          props_json = response_agent.request[type_class_name][action]
          props = Oj.load(props_json, mode: :strict)
          props.merge!(pub_sub_client: pub_sub_client, current_user: current_user)
          if current_user.authorized?(type_class, :store, props)
            stored_type = type_class.new(**props).store
            on_store_block = type_class.instance_variable_get(:@_on_store_block)
            stored_type.instance_exec(pub_sub_client, current_user, &on_store_block) if on_store_block
            response_agent.outer_result = { data: stored_type.to_transport }
            response_agent.agent_result = { success: 'ok' }
          else response_agent.error = { error: 'Access denied!' }
          end
        end

        #def process_destroy(pub_sub_client, current_user, response_agent, type_class, type_class_name, action)
        #  props_json = response_agent.request[type_class_name][action]
        #  props = Oj.load(props_json, mode: :strict)
        #  props.merge!(pub_sub_client: pub_sub_client, current_user: current_user)
        #  if current_user.authorized?(type_class, :store, *props)
        #    # TODO
        #    stored_type.instance_exec do
        #      type_class.on_store_block.call(pub_sub_client, current_user) if type_class.on_store_block
        #    end
        #    destroyed = type_class.destroy(**props)
        #    response_agent.outer_result = { data: stored_type.to_transport }
        #    response_agent.agent_result = { success: 'ok' }
        #  else response_agent.error = { error: 'Access denied!' }
        #  end
        #end
      end
    end
  end
end
