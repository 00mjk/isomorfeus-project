module Isomorfeus
  module Installer
    module OptionsMangler
      def self.mangle_options(options)
        if options.key?(:rack_server) && Isomorfeus::Installer.sorted_rack_servers.include?(options[:rack_server])
          Isomorfeus::Installer.rack_server = Isomorfeus::Installer.rack_servers[options[:rack_server]]
          Isomorfeus::Installer.rack_server_name = options[:rack_server]
        else
          Isomorfeus::Installer.rack_server = Isomorfeus::Installer.rack_servers['iodine']
        end
        Isomorfeus::Installer.source_dir = File.expand_path(options[:source_dir]) if options.key?(:source_dir)
        Isomorfeus::Installer.isomorfeus_module = "isomorfeus-#{options[:module]}".to_sym if options.key?(:module)
      end
    end
  end
end
