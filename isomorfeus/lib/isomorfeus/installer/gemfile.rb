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
          line << ", require: false" if gem_hash.has_key?(:require) && !gem_hash[:require]
          line << "\n"
        end

        def install_gemfile
          rack_server_gems = ''
          Isomorfeus::Installer.rack_servers[Isomorfeus::Installer.options[:rack_server]]&.fetch(:gems)&.each do |gem|
            rack_server_gems << generate_gem_line(gem)
          end
          data_hash = { rack_server_gems: rack_server_gems.chop }
          if Isomorfeus::Installer.source_dir
            %i[isomorfeus isomorfeus_data isomorfeus_i18n isomorfeus_mailer isomorfeus_operation isomorfeus_policy isomorfeus_transport].each do |i_module|
              data_hash[i_module] = i_module == Isomorfeus::Installer.isomorfeus_module ? "path: '..'" : "path: '../../#{i_module.to_s.tr('_', '-')}'"
            end
            if File.exist?("gems/gems/isomorfeus-professional-#{Isomorfeus::VERSION}.gem")
              data_hash[:isomorfeus_professional] = "path: '../../../../'"
            else
              data_hash[:isomorfeus_professional] = false
            end
            data_hash[:isomorfeus_edition] = :test
          else
            data_hash[:isomorfeus_edition] = Isomorfeus::Installer.is_professional ? :professional : :community
            data_hash[:isomorfeus_version] = "'~> #{Isomorfeus::VERSION}'"
          end

          create_file_from_template(Isomorfeus::Installer.templates_path, 'Gemfile.erb', 'Gemfile', data_hash)
        end
      end
    end
  end
end
