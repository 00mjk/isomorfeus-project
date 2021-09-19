module Isomorfeus
  # available settings
  class << self
    def instance_from_sid(sid)
      data_class = cached_data_class(sid[0])
      data_class.new(key: sid[1])
    end

    if RUBY_ENGINE == 'opal'
      def cached_data_classes
        @cached_data_classes ||= `{}`
      end

      def cached_data_class(class_name)
        return "::#{class_name}".constantize if Isomorfeus.development?
        return cached_data_classes.JS[class_name] if cached_data_classes.JS[class_name]
        cached_data_classes.JS[class_name] = "::#{class_name}".constantize
      end
    else
      def cached_data_classes
        @cached_data_classes ||= {}
      end

      def cached_data_class(class_name)
        return "::#{class_name}".constantize if Isomorfeus.development?
        return cached_data_classes[class_name] if cached_data_classes.key?(class_name)
        cached_data_classes[class_name] = "::#{class_name}".constantize
      end

      def valid_data_classes
        @valid_data_classes ||= {}
      end

      def valid_data_class_name?(class_name)
        valid_data_classes.key?(class_name)
      end

      def add_valid_data_class(klass)
        valid_data_classes[raw_class_name(klass)] = true
      end

      def valid_file_classes
        @valid_file_classes ||= {}
      end

      def valid_file_class_name?(class_name)
        valid_file_classes.key?(class_name)
      end

      def add_valid_file_class(klass)
        valid_file_classes[raw_class_name(klass)] = true
      end
      
      attr_accessor :files_path
    end
  end

  if RUBY_ENGINE != 'opal'
    self.files_path = File.expand_path(File.join(Isomorfeus.root, 'data', 'files'))
  end
end