module Isomorfeus
  class CLI < Thor

    desc "new project_name", "Create a new isomorfeus project with project_name."
    option :rack_server, default: 'iodine', aliases: '-r',
           desc: "Select rack server, one of: #{Isomorfeus::Installer.sorted_rack_servers.join(', ')}."
    option :targets, default: 'web', required: false, type: :string, aliases: '-t', desc: <<~DESC
Select targets to install.
Available targets:
  web: Create web applications
  mobile: Create mobile applications with React Native #{'(Requires Isomorfeus Professional)' unless Isomorfeus::Installer.is_professional}
  desktop: Create desktop applications with Electron #{'(Requires Isomorfeus Professional)' unless Isomorfeus::Installer.is_professional}
Example:
  -t "web mobile desktop" - Setup project for all targets
  -t mobile               - Setup project for mobile applications only
DESC
    option :yarn_and_bundle, default: 'yes', required: false, type: :string, aliases: '-y',
           desc: "Execute yarn install and bundle install: -y or -y yes, do not execute: -y no"
    def new(project_name)
      Isomorfeus::Installer.set_project_names(project_name)
      Isomorfeus::Installer.options = options
      begin
        Dir.mkdir(Isomorfeus::Installer.project_dir)
        Dir.chdir(Isomorfeus::Installer.project_dir)
      rescue
        puts "Directory #{installer.project_dir} could not be created!"
        exit 1
      end
      Isomorfeus::Installer::NewProject.execute
      Isomorfeus::Installer::InstallTargets.execute
      Isomorfeus::Installer::Gemfile.execute
      Isomorfeus::Installer::YarnAndBundle.execute
      Dir.chdir('..')
    end

    desc "add_target target", "Add a target to a existing Isomorfeus Project."
    long_desc <<~DESC
Add a target to a existing Isomorfeus Project.
\x5
\x5Available targets:
\x5  web: Create web applications
\x5  mobile: Create mobile applications with React Native #{'(Requires Isomorfeus Professional)' unless Isomorfeus::Installer.is_professional}
\x5  desktop: Create desktop applications with Electron #{'(Requires Isomorfeus Professional)' unless Isomorfeus::Installer.is_professional}
\x5
\x5  Example:
\x5  isomorfeus add_target mobile - Add mobile as target to a existing project
\x5  isomorfeus add_target web    - Add web as target to a existing project
DESC
    option :yarn_and_bundle, default: 'yes', required: false, type: :string, aliases: '-y',
           desc: "Execute yarn install and bundle install: -y or -y yes, do not execute: -y no"
    def add(project_name)
      Isomorfeus::Installer.set_project_names(project_name)
      Isomorfeus::Installer.options = options
      Isomorfeus::Installer::InstallTargets.execute
      Isomorfeus::Installer::Gemfile.execute
      Isomorfeus::Installer::YarnAndBundle.execute
    end

    desc "console", "Open console for current project."
    def console
      Isomorfeus::Console.new.run
    end

    desc "upgrade", "Install updated config and provide hints for upgrading."
    option :yarn_and_bundle, default: 'yes', required: false, type: :string, aliases: '-y',
           desc: "Execute yarn install and bundle install: -y or -y yes, do not execute: -y no"
    def upgrade
      Isomorfeus::Installer::Upgrade.execute
      Isomorfeus::Installer::YarnAndBundle.execute
    end

    desc "versions", "Show versions of important Isomorfeus gems"
    def versions
      output = ''
      %w[arango-driver arango-driver-professional opal-webpack-loader isomorfeus-redux isomorfeus-react isomorfeus-data isomorfeus-i18n isomorfeus-mailer isomorfeus-operation
         isomorfeus-policy isomorfeus-transport isomorfeus isomorfeus-professional].each do |gem|
        o = `bundle info #{gem} 2>&1`
        o.each_line do |line|
          output << line if line.include?('*') && line.include?(gem)
        end
      end
      puts output
    end

    desc "test_app", "Create a test_app for internal framework tests."
    option :module, required: true, type: :string, aliases: '-m',
           desc: "Isomorfeus module name for which to generate the test app, eg: 'i18n'. (required)"
    option :source_dir, required: true, type: :string, aliases: '-s',
           desc: "Recursively copy files from source dir into app. (optional)"
    option :targets, default: 'web', required: false, type: :string, aliases: '-t', desc: <<~DESC
Select targets to install.
Available targets:
  web: Create web applications (default)
  mobile: Create mobile applications with React Native #{'(Requires Isomorfeus Professional)' unless Isomorfeus::Installer.is_professional}
  desktop: Create desktop applications with Electron #{'(Requires Isomorfeus Professional)' unless Isomorfeus::Installer.is_professional}
Example:
  ismos new my_project -t "web mobile desktop" - Setup project for all targets
  ismos new my_project -t mobile               - Setup project for mobile applications only
DESC
    option :rack_server, default: 'iodine', aliases: '-r',
           desc: "Select rack server, one of: #{Isomorfeus::Installer.sorted_rack_servers.join(', ')}. (optional, default: iodine)"
    option :yarn_and_bundle, default: 'yes', required: false, type: :string, aliases: '-y',
           desc: "Execute yarn install and bundle install: -y or -y yes, do not execute: -y no"
    def test_app
      Isomorfeus::Installer.set_project_names('test_app')
      Isomorfeus::Installer.options = options
      begin
        Dir.mkdir(Isomorfeus::Installer.project_dir)
        Dir.chdir(Isomorfeus::Installer.project_dir)
      rescue
        puts "Directory #{installer.project_dir} could not be created!"
        exit 1
      end
      Isomorfeus::Installer::NewProject.execute
      Isomorfeus::Installer::InstallTargets.execute
      Isomorfeus::Installer::Gemfile.execute
      Isomorfeus::Installer::TestAppFiles.execute
      Isomorfeus::Installer::YarnAndBundle.execute
      Dir.chdir('..')
    end
  end
end
