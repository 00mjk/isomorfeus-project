module LucidQuickOp
  module Mixin
    def self.included(base)
      base.extend(LucidPropDeclaration::Mixin)

      if RUBY_ENGINE == 'opal'
        base.instance_exec do
          def op
          end

          def promise_run(**props_hash)
            props = validated_props(props_hash)
            Isomorfeus::Transport.promise_send_path('Isomorfeus::Operation::Handler::OperationHandler', self.name, props).then do |agent|
              unless agent.processed
                agent.processed = true
                if agent.response.key?(:error)
                  `console.error(#{agent.response[:error].to_n})`
                  Isomorfeus.raise_error(message: agent.response[:error])
                end
                agent.result = agent.response[:result]
              end
              if agent.result.key?(:rejected)
                if agent.result.key?(:error)
                  e = agent.result[:error]
                  exception_class_name = e[:class_name]
                  exception_class = exception_class_name.constantize
                  exception = exception_class.new(e[:message])
                  exception.set_backtrace(e[:backtrace])
                  raise exception
                else
                  raise agent.result[:rejected]
                end
              else
                agent.result[:resolved]
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

          def promise_run(**props_hash)
            self.new(**props_hash).promise_run
          end
        end
      end
    end

    attr_reader :props

    def initialize(**props_hash)
      props_hash = self.class.validated_props(props_hash)
      @props = LucidProps.new(props_hash)
    end

    def promise_run
      original_promise = Promise.new

      operation = self
      promise = original_promise.then do |_|
        operation.instance_exec(&operation.class.instance_variable_get(:@op))
      end

      original_promise.resolve
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
