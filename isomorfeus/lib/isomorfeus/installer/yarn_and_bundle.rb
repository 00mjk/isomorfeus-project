module Isomorfeus
  module Installer
    class YarnAndBundle
      class << self
        def execute
          yandle = Isomorfeus::Installer.options[:yarn_and_bundle]
          if yandle == 'yes'
            puts 'Executing yarn install:'
            Bundler.with_original_env do
              if Gem.win_platform?
                system('yarn install')
              else
                system('env -i PATH="$PATH" yarn install')
              end
            end
            puts 'Executing bundle install:'
            bundle_command =  Gem.bin_path("bundler", "bundle")
            Bundler.with_original_env do
              system("#{Gem.ruby} #{bundle_command} install")
            end
          end
        end
      end
    end
  end
end
