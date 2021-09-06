module Isomorfeus
  module Installer

    class << self
      # application options
      attr_reader   :app_class
      attr_accessor :database
      attr_accessor :framework
      attr_accessor :isomorfeus_module
      attr_reader   :project_dir
      attr_reader   :project_name
      attr_accessor :rack_server
      attr_accessor :rack_server_name
      attr_reader   :roda_app_class
      attr_reader   :roda_app_path
      attr_accessor :source_dir

      # installer options
      attr_reader :options
      
      def set_project_names(pro_dir)
        @project_dir    = pro_dir
        @project_name   = pro_dir.underscore
        @app_class      = @project_name.camelize + 'App'
        @roda_app_class = @project_name.camelize + 'RodaApp'
        @roda_app_path  = @project_name + '_roda_app'
      end

      def options=(options)
        Isomorfeus::Installer::OptionsMangler.mangle_options(options)
        @options = options
      end

      def add_rack_server(name, props)
        rack_servers[name] = props
      end

      def rack_servers
        @rack_servers ||= {}
      end

      def sorted_rack_servers
        rack_servers.keys.sort
      end

      # installer paths

      def base_path
        @base_path ||= File.realpath(File.join(File.dirname(File.realpath(__FILE__)), 'installer'))
      end

      def templates_path
        @templates_path ||= File.realpath(File.join(File.dirname(File.realpath(__FILE__)), 'installer', 'templates'))
      end
    end
  end
end
