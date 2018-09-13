module Isomorfeus
  class Operation
    class SecurityError < StandardError
    end

    module SecurityGuards
      def guarded_operation_class(model_name)
        return nil unless Isomorfeus.valid_operation_class_names.include?(model_name) # guard
        model_name.camelize.constantize
      end

      def guarded_operation_class!(model_name)
        raise Isomorfeus::Operation::SecurityError unless Isomorfeus.valid_operation_class_names.include?(model_name) # guard
        model_name.camelize.constantize
      end
    end
  end
end
