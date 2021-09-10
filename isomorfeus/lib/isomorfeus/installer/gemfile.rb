module Isomorfeus
  module Installer
    class Gemfile
      extend Isomorfeus::Installer::DSL

      class << self
        def execute
          install_gemfile
        end

        def generate_gem_line(gem_hash)
          line = "gem '#{gem_hash[:name]}', '#{gem_hash[:version]}'"
          line << ", require: false" if gem_hash.key?(:require) && !gem_hash[:require]
          line << "\n"
        end

        def install_gemfile
          rack_server_gems = ''
          Isomorfeus::Installer.rack_servers[Isomorfeus::Installer.options[:rack_server]]&.fetch(:gems)&.each do |gem|
            rack_server_gems << generate_gem_line(gem)
          end
          data_hash = { rack_server_gems: rack_server_gems.chop }

          if Isomorfeus::Installer.project_name == 'test_app'
            gem_lines = ''
            %i[isomorfeus isomorfeus-data isomorfeus-i18n isomorfeus-mailer isomorfeus-operation isomorfeus-policy isomorfeus-transport].each do |i_module|
              gem_lines << "gem '#{i_module}', path: #{Isomorfeus::Installer.isomorfeus_module == i_module ? "'..'" : "'../../#{i_module}'"}\n"
            end
            data_hash[:isomorfeus_gems] = gem_lines.chop
          else
            data_hash[:isomorfeus_gems] = "gem 'isomorfeus', '~> #{Isomorfeus::VERSION}'" 
          end

          create_file_from_template(Isomorfeus::Installer.templates_path, 'Gemfile.erb', 'Gemfile', data_hash)
        end
      end
    end
  end
end
