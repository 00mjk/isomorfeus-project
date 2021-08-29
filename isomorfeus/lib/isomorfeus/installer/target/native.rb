module Isomorfeus
  module Installer
    module Target
      class Native
        extend Isomorfeus::Installer::DSL

        GETTING_STARTED_URI = 'https://reactnative.dev/docs/getting-started'
        TEMPLATE_DIR = File.expand_path(File.join(__dir__, '..', '..', 'professional', 'templates'))
        METRO_PACKAGE_REPO = "https://github.com/isomorfeus/metro-package.git"
        METRO_RESOLVER_PACKAGE_REPO = "https://github.com/isomorfeus/metro-resolver-package.git"
        REACT_NATIVE_PACKAGE_REPO = "https://github.com/isomorfeus/react-native-package.git"

        class << self
          def execute
            @android_sdk_installed = false
            @xcode_installed = false

            check_preconditions
            precondition_error unless @android_sdk_installed || @xcode_installed

            add_npm_packages

            yarn_install

            create_react_native_project

            move_many_files_around
            merge_some_files
            remove_remaining_things
            create_new_files

            pod_install
          end

          def add_npm_packages
            package_file = File.read('package.json')
            package_json = Oj.load(package_file, mode: :strict)
            mobile_package_file = File.read(File.join(TEMPLATE_DIR, 'native_package.json'))
            mobile_package_json = Oj.load(mobile_package_file, mode: :strict)
            new_package_json = package_json.deep_merge(mobile_package_json)
            File.write('package.json', Oj.dump(new_package_json, mode: :strict))
          end

          def yarn_install
            system('yarn install')
          end

          def pod_install
            if @cocoa_installed
              pwd = Dir.pwd
              Dir.chdir('ios')
              Bundler.with_original_env do
                system('pod install')
              end
              Dir.chdir(pwd)
            end
          end

          def create_react_native_project
            npm_bin = `npm bin`.strip
            template_path = File.expand_path('react_native_template')
            Bundler.with_original_env do
              system("#{npm_bin}/react-native init #{Isomorfeus::Installer.app_class} --directory react_native_project --version 0.61.5 --template #{REACT_NATIVE_PACKAGE_REPO}")
            end
          end

          def move_many_files_around
            %w[
              .buckconfig
              .eslintrc.js
              .flowconfig
              .gitattributes
              .prettierrc.js
              .watchmanconfig
              __tests__
              android
              app.json
              babel.config.js
              ios
            ].each do |path|
              FileUtils.mv(File.join('react_native_project', path), path)
            end
          end

          def merge_some_files
            merge_gitignore
            merge_package_json
          end

          def remove_remaining_things
            FileUtils.rm_rf('react_native_project')
            FileUtils.rm_rf('react_native_template')
          end

          def create_new_files
            copy_file(File.join(TEMPLATE_DIR, 'index.js'), 'index.js')
            copy_file(File.join(TEMPLATE_DIR, 'metro.config.js'), 'metro.config.js')
            copy_file(File.join(TEMPLATE_DIR, 'native_loader.rb'), File.join('app',  'native_loader.rb'))
            data_hash = { app_class: Isomorfeus::Installer.app_class }
            create_file_from_template(TEMPLATE_DIR, 'native.js.erb',
                                      File.join('app', 'imports', 'native.js'), data_hash)
          end

          def merge_gitignore
            current_gitignore = File.read('.gitignore')
            native_gitignore = File.read(File.join('react_native_project', '.gitignore'))
            new_gitignore = current_gitignore + native_gitignore
            File.write('.gitignore', new_gitignore)
          end

          def merge_package_json
            current_package_json = File.read('package.json')
            current_packages = Oj.load(current_package_json, mode: :strict)
            native_package_json = File.read(File.join('react_native_project', 'package.json'))
            native_packages = Oj.load(native_package_json, mode: :strict)
            new_packages = current_packages.deep_merge(native_packages)
            new_packages['dependencies']['metro'] = METRO_PACKAGE_REPO
            new_packages['dependencies']['metro-resolver'] = METRO_RESOLVER_PACKAGE_REPO
            new_packages['dependencies']['react-native'] = REACT_NATIVE_PACKAGE_REPO
            new_package_json = Oj.dump(new_packages, mode: :strict, indent: 2)
            File.write('package.json', new_package_json)
          end

          def check_preconditions
            check_androidsdk
            check_xcode
            check_cocoapods
          end

          def check_androidsdk
            list = `sdkmanager --list`
            @android_sdk_installed = true
            puts "Found AndroidSDK."
          rescue
            @android_sdk_installed = false
            puts "Could not find AndroidSDK."
          end

          def check_xcode
            version = `xcode-select -version`
            @xcode_installed = true
            puts "Found Xcode."
          rescue
            @xcode_installed = false
            puts "Could not find proper Xcode installation. xcode-select must be available."
          end

          def check_cocoapods
            version = nil
            Bundler.with_original_env do
              version = `pod -version`
            end
            @cocoa_installed = true
            puts "Found CocoaPods."
          rescue
            @cocoa_installed = false
            puts "Could not find CocoaPods."
          end

          def precondition_error
            STDERR.puts
            STDERR.puts "Could not find Android SDK or XCode!"
            STDERR.puts "Please follow instructions at #{GETTING_STARTED_URI} to install requirements!"
            STDERR.puts
            exit 23
          end
        end
      end
    end
  end
end
