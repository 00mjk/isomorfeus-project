module LucidQuickOp
  module Mixin
    def self.included(base)
      base.extend(LucidPropDeclaration::Mixin)

      if RUBY_ENGINE == 'opal'
        base.instance_exec do
          def op
          end

          def promise_run(props_hash = nil)
            props_hash = props_hash || props
            validate_props(props_hash)
            props_json = Isomorfeus::PropsProxy.new(props_hash).to_json
            Isomorfeus::Transport.promise_send_path('Isomorfeus::Operation::Handler::OperationHandler', self.name, props_json).then do |agent|
              if agent.processed
                agent.result
              else
                agent.processed = true
                if agent.response.key?(:error)
                  `console.error(#{agent.response[:error].to_n})`
                  Isomorfeus.raise_error(message: agent.response[:error])
                end
                agent.result = agent.response[:result]
              end
            end
          end
        end
      else
        Isomorfeus.add_valid_operation_class(base) unless base == LucidQuickOp::Base

        base.instance_exec do
          def op(&block)
            @op = block
          end

          def promise_run(props_hash = nil)
            props_hash = props_hash || props
            validate_props(props_hash)
            self.new(props_hash).promise_run
          end
        end
      end
    end

    attr_accessor :props

    def initialize(validated_props_hash)
      @props = Isomorfeus::PropsProxy.new(validated_props_hash)
      @on_fail_track = false
    end

    def promise_run
      original_promise = Promise.new

      operation = self
      promise = original_promise.then do |result|
        operation.instance_exec(&self.class.instance_variable_get(:@op))
      end

      original_promise.resolve(true)
      promise
    end

    def current_user
      Isomorfeus.current_user
    end

    def pub_sub_client
      Isomorfeus.pub_sub_client
    end
  end
end
