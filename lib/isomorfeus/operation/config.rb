module Isomorfeus
  class << self
    def cached_operation_classes
      @cached_operation_classes ||= {}
    end

    def cached_operation_class(class_name)
      return cached_operation_classes[class_name] if cached_operation_classes.key?(class_name)
      cached_operation_classes[class_name] = "::#{class_name}".constantize
    end

    if RUBY_ENGINE != 'opal'
      def valid_operation_class_names
        @valid_operation_class_names ||= Set.new
      end

      def valid_operation_class_name?(class_name)
        valid_operation_class_names.include?(class_name)
      end

      def add_valid_operation_class(klass)
        class_name = klass.name
        class_name = class_name.split('>::').last if class_name.start_with?('#<')
        valid_operation_class_names << class_name
      end
    end
  end
end
