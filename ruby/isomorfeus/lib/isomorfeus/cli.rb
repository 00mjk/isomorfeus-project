module Isomorfeus
  class CLI < Thor

    desc "new project_name", "Create a new isomorfeus project with project_name."
    option :rack_server, default: 'iodine', aliases: '-r',
           desc: "Select rack server, one of: #{Isomorfeus::Installer.sorted_rack_servers.join(', ')}."
    option :targets, default: 'web', required: false, type: :string, aliases: '-t', desc: <<~DESC
Select targets to install.
Available targets:
  web: Create web applications
  native: Create applications with React Native (Requires #{'Isomorfeus Professional and the' unless Isomorfeus::Installer.is_professional} web target)'
  all: web + native
Example:
  -t all          - Setup project for all targets
  -t "web native" - Setup project for all targets
  -t web          - Setup project for web applications only
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
\x5  native: Create applications with React Native (Requires #{'Isomorfeus Professional and the' unless Isomorfeus::Installer.is_professional} web target)'
\x5
\x5  Example:
\x5  isomorfeus add_target native - Add mobile as target to a existing project
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
    option :targets, default: 'web', required: false, type: :string, aliases: '-t',
           desc: 'Select targets to install.'
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
