module Isomorfeus
  module Installer
    class NewProject
      extend Isomorfeus::Installer::DSL

      def self.execute
        begin
          create_common_framework_directories
          install_basic_components
          install_basic_policy
          install_spec_helper
        rescue Exception => e
          puts e.backtrace.join("\n")
          puts "Installation failed: #{e.message}"
        end
      end
    end
  end
end
