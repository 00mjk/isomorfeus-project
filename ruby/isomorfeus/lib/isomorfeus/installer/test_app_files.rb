module Isomorfeus
  module Installer
    module TestAppFiles
      class << self
        def execute
          copy_test_app_files if Isomorfeus::Installer.source_dir
        end
      end
    end
  end
end
