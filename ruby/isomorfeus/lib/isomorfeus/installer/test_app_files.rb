module Isomorfeus
  module Installer
    module TestAppFiles
      extend Isomorfeus::Installer::DSL

      class << self
        def execute
          copy_test_app_files if Isomorfeus::Installer.source_dir
        end

        def copy_test_app_files
          Dir.glob("#{Isomorfeus::Installer.source_dir}/**/*").each do |file|
            if File.file?(file)
              target_file = file[(Isomorfeus::Installer.source_dir.size+1)..-1]
              target_dir = File.dirname(target_file)
              Dir.mkdir(target_dir) unless Dir.exist?(target_dir)
              copy_file(file, target_file)
            end
          end
        end
      end
    end
  end
end
