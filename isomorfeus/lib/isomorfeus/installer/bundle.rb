module Isomorfeus
  module Installer
    class Bundle
      def self.execute
        puts 'Executing bundle install:'
        bundle_command = Gem.bin_path("bundler", "bundle")
        Bundler.with_original_env do
          system("#{Gem.ruby} #{bundle_command} install")
        end
      end
    end
  end
end
