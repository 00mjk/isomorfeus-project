module Isomorfeus
  class << self
    def cached_policy_classes
      @cached_array_classes ||= {}
    end

    def cached_policy_class(class_name)
      return "::#{class_name}".constantize if Isomorfeus.development?
      return cached_policy_classes[class_name] if cached_policy_classes.key?(class_name)
      cached_policy_classes[class_name] = "::#{class_name}".constantize
    end

    if RUBY_ENGINE != 'opal'
      attr_accessor :zeitwerk
      attr_accessor :zeitwerk_lock

      def valid_policy_class_names
        @valid_policy_class_names ||= Set.new
      end

      def valid_policy_class_name?(class_name)
        valid_policy_class_names.include?(class_name)
      end

      def add_valid_policy_class(klass)
        class_name = klass.name
        class_name = class_name.split('>::').last if class_name.start_with?('#<')
        valid_policy_class_names << class_name
      end
    end
  end
end
