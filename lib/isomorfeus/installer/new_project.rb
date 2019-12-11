require 'opal-webpack-loader/installer_cli'
require 'opal-webpack-loader/version'

module Isomorfeus
  module Installer
    class NewProject
      def self.execute(yarn_and_bundle: true)
        begin
          Dir.mkdir(Isomorfeus::Installer.project_dir)
          Dir.chdir(Isomorfeus::Installer.project_dir)
        rescue
          puts "Directory #{installer.project_dir} could not be created!"
          exit 1
        end

        begin
          Isomorfeus::Installer.create_directories
          Isomorfeus::Installer.install_framework

          OpalWebpackLoader::Installer::CLI.start(['iso'])
          Isomorfeus::Installer.install_webpack_config

          Isomorfeus::Installer.install_styles
          Isomorfeus::Installer.install_js_entries
          Isomorfeus::Installer.install_isomorfeus_entries

          Isomorfeus::Installer.create_components
          Isomorfeus::Installer.create_policy
          Isomorfeus::Installer.create_spec

          Isomorfeus::Installer.create_package_json
          Isomorfeus::Installer.create_gemfile
          Isomorfeus::Installer.create_procfile

          Isomorfeus::Installer.copy_source_dir_files if Isomorfeus::Installer.source_dir

          if yarn_and_bundle
            puts 'Executing yarn install:'
            system('env -i PATH=$PATH yarn install')
            puts 'Executing bundle install:'
            bundle_command =  Gem.bin_path("bundler", "bundle")
            Bundler.with_original_env do
              system("#{Gem.ruby} #{bundle_command} install")
            end
          end

          Dir.chdir('..')
          puts 'Project setup finished, make your dreams come true :)'
        rescue Exception => e
          puts e.backtrace.join("\n")
          puts "Installation failed: #{e.message}"
        end
      end
    end
  end
end
