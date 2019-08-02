module LucidQuickOp
  module Mixin
    def self.included(base)
      if RUBY_ENGINE != 'opal'
        Isomorfeus.add_valid_operation_class(base) unless base == LucidQuickOp::Base
      end

      base.extend(Isomorfeus::Data::PropDeclaration)

      if RUBY_ENGINE == 'opal'
        base.instance_exec do
          def op
          end

          def promise_run(props_hash)
            validate_props(props_hash)
            props_json = Isomorfeus::Data::Props.new(props_hash).to_json
            Isomorfeus::Transport.promise_send_path('Isomorfeus::Operation::Handler::OperationHandler', self.name, props_json)
          end
        end
      else
        base.instance_exec do
          def op(&block)
            @op = block
          end

          def promise_run(props_hash)
            validate_props(props_hash)
            self.new(props_hash).promise_run
          end
        end
      end
    end

    attr_accessor :props

    def initialize(validated_props_hash)
      @props = Isomorfeus::Data::Props.new(validated_props_hash)
      @on_fail_track = false
    end

    def promise_run
      promise = Promise.new
      operation = self
      promise.then do |result|
        operation.instance_exec(@op.call)
      end

      promise.resolve(true)
    end
  end
end
