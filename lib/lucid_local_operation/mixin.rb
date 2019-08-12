module LucidLocalOperation
  module Mixin
    def self.included(base)
      if RUBY_ENGINE != 'opal'
        Isomorfeus.add_valid_operation_class(base) unless base == LucidLocalOperation::Base
      end

      base.extend(Isomorfeus::Data::PropDeclaration)
      base.extend(Isomorfeus::Operation::Mixin)
      base.include(Isomorfeus::Operation::PromiseRun)

      base.instance_exec do
        def promise_run(props_hash)
          validate_props(props_hash)
          self.new(props_hash).promise_run
        end
      end
    end

    attr_accessor :props
    attr_accessor :step_result
  end
end
