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

      def connect_to_arango
        arango_options = if Isomorfeus.production? then Isomorfeus.arango_production
                         elsif Isomorfeus.development? then Isomorfeus.arango_development
                         elsif Isomorfeus.test? then Isomorfeus.arango_test
                         end
        arango_options = {}.merge(arango_options)
        database = arango_options.delete(:database)
        Arango.connect_to(**arango_options)
        begin
          Arango.current_server.get_database(database)
        rescue Exception => e
          Isomorfeus.raise_error(message: "Can't connect to database '#{database}' (#{e.message}).")
        end
      end

      def prepare_arango_database
        unless arango_configured?
          STDOUT.puts "ArangoDB not configured, not preparing things, not using ArangoDB"
          return
        end
        arango_options = if Isomorfeus.production? then Isomorfeus.arango_production
                        elsif Isomorfeus.development? then Isomorfeus.arango_development
                        elsif Isomorfeus.test? then Isomorfeus.arango_test
                         end
        arango_options = {}.merge(arango_options)
        database = arango_options.delete(:database)
        Arango.connect_to(**arango_options)
        db = nil
        begin
         opened_db = Arango.current_server.get_database(database)
         db = opened_db.name
        rescue Exception => e
         db = nil
         unless e.message.include?('database not found')
           Isomorfeus.raise_error(message: "Can't check if database '#{database}' exists.")
         end
        end
        unless db
         begin
           Arango.current_server.create_database(database)
         rescue Exception => e
           Isomorfeus.raise_error(message: "Can't create database '#{database}' (#{e.message}).\nPlease make sure database '#{database}' exists.")
         end
         begin
           Arango.current_server.get_database(database)
         rescue Exception => e
           Isomorfeus.raise_error(message: "Can't connect to database '#{database}' (#{e.message}).")
         end
        end

        Arango.current_server.install_opal_module(database)
        unless Arango.current_database.collection_exist?('IsomorfeusSessions')
         Arango.current_database.create_collection('IsomorfeusSessions')
        end
        unless Arango.current_database.collection_exist?('IsomorfeusObjectStore')
         Arango.current_database.create_collection('IsomorfeusObjectStore')
        end
      end

      def arango_configured?
        (defined? ::Arango) && !!(Isomorfeus.arango_production && Isomorfeus.arango_development && Isomorfeus.arango_test)
      end

      attr_accessor :arango_production
      attr_accessor :arango_development
      attr_accessor :arango_test
      attr_accessor :file_request_path
    end
    self.file_request_path = '/isomorfeus/files'
  end
end
