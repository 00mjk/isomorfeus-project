module Isomorfeus
  class CLI < Thor

    desc "new project_name", "Create a new isomorfeus project with project_name."
    option :rack_server, default: 'iodine', aliases: '-r',
           desc: "Select rack server, one of: #{Isomorfeus::Installer.sorted_rack_servers.join(', ')}. (optional)"
    option :yarn_and_bundle, default: true, required: false, type: :boolean, aliases: '-y', desc: "Execute yarn install and bundle install. (optional)"
    def new(project_name)
      Isomorfeus::Installer.set_project_names(project_name)
      Isomorfeus::Installer.options = options
      Isomorfeus::Installer::NewProject.execute(yarn_and_bundle: options[:yarn_and_bundle])
    end

    desc "console", "Open console for current project."
    def console
      Isomorfeus::Console.new.run
    end

    desc "test_app", "Create a test_app for internal framework tests."
    option :module, required: true, type: :string, aliases: '-m', desc: "Isomorfeus module name for which to generate the test app, eg: 'i18n'. (required)"
    option :source_dir, required: false, type: :string, aliases: '-s', desc: "Recursively copy files from source dir into app. (optional)"
    option :rack_server, default: 'iodine', aliases: '-r',
           desc: "Select rack server, one of: #{Isomorfeus::Installer.sorted_rack_servers.join(', ')}. (optional)"
    option :yarn_and_bundle, default: true, required: false, type: :boolean, aliases: '-y', desc: "Execute yarn install and bundle install. (optional)"
    def test_app
      Isomorfeus::Installer.set_project_names('test_app')
      Isomorfeus::Installer.options = options
      Isomorfeus::Installer::NewProject.execute(yarn_and_bundle: options[:yarn_and_bundle])
    end
  end
end
