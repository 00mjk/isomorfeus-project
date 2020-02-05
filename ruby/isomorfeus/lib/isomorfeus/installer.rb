module Isomorfeus
  module Installer
    # driver support

    def self.add_database(name, props)
      databases[name] = props
    end

    def self.add_rack_server(name, props)
      rack_servers[name] = props
    end

    class << self
      # application options
      attr_reader   :app_class
      attr_reader   :app_require
      attr_accessor :database
      attr_accessor :framework
      attr_accessor :isomorfeus_module
      attr_reader   :project_dir
      attr_reader   :project_name
      attr_accessor :rack_server
      attr_accessor :rack_server_name
      attr_accessor :source_dir

      # installer options
      attr_reader :options
    end

    def self.set_project_names(pro_dir)
      @project_dir    = pro_dir
      @project_name   = pro_dir.underscore
      @app_class      = @project_name.camelize + 'App'
      @app_require    = @project_name + '_app'
    end

    def self.options=(options)
      Isomorfeus::Installer::OptionsMangler.mangle_options(options)
      @options = options
    end

    def self.sorted_databases
      databases.keys.sort
    end

    def self.sorted_policies
      policies.keys.sort
    end

    def self.sorted_rack_servers
      rack_servers.keys.sort
    end

    def self.databases
      @databases ||= {}
    end

    def self.policies
      @policies ||= {}
    end

    def self.rack_servers
      @rack_servers ||= {}
    end

    # installer options and config

    def self.module_directories
      %w[databases]
    end

    # installer paths

    def self.base_path
      @base_path ||= File.realpath(File.join(File.dirname(File.realpath(__FILE__)), 'installer'))
    end

    def self.templates_path
      @templates_path ||= File.realpath(File.join(File.dirname(File.realpath(__FILE__)), 'installer', 'templates'))
    end

    # app paths

    def self.asset_output_path
      File.join('public', 'assets')
    end

    def self.entrypoint_path(entrypoint)
      File.join(isomorfeus_path, 'imports', entrypoint)
    end

    def self.isomorfeus_path
      'app'
    end

    def self.webpack_config_path(config_file)
      File.join( 'webpack', config_file)
    end

    def self.stylesheet_path(stylesheet)
      File.join(isomorfeus_path, 'styles', stylesheet)
    end

    def self.middlewares_includes
      'extend Isomorfeus::Transport::Middlewares'
    end

    # install helpers

    def self.generate_gem_line(gem_hash)
      line = "gem '#{gem_hash[:name]}', '#{gem_hash[:version]}'"
      line << ", require: false" if gem_hash.has_key?(:require) && !gem_hash[:require]
      line << "\n"
    end

    def self.create_directories
      # no created: handlers
      %w[channels components data imports locales mail_components operations policies server styles].each do |isomorfeus_dir|
        create_directory(File.join(isomorfeus_path, isomorfeus_dir))
      end
      create_directory('spec')
    end

    def self.create_directory(directory)
      unless Dir.exist?(directory)
        puts "Creating directory #{directory}."
        FileUtils.mkdir_p(directory)
        FileUtils.touch(File.join(directory, '.keep'))
      end
    end

    def self.create_file_from_template(template_path, target_file_path, data_hash)
      template = ERB.new(File.read(File.join(templates_path, template_path), mode: 'r'))
      result = template.result_with_hash(data_hash)
      ext = File.exist?(target_file_path) ? '_new' : ''
      File.write(target_file_path + ext, result, mode: 'w')
    end

    def self.install_framework
      data_hash = { app_class:                      app_class,
                    middlewares:                    create_middlewares,
                    middlewares_includes:           middlewares_includes,
                    rack_server_init:               rack_server[:rack_server_init] }
      create_file_from_template('app.rb.erb', "#{@project_name}_app.rb", data_hash)
      create_file_from_template( rack_server[:init_template], rack_server[:init_template][0..-5], {})
      data_hash = { app_require: app_require, app_class: app_class }
      create_file_from_template('config.ru.erb', 'config.ru', data_hash)
      create_file_from_template(File.join('app_loader.rb.erb'), 'app_loader.rb', {})
      create_file_from_template(File.join('arango_config.rb.erb'), 'arango_config.rb', data_hash )
      create_file_from_template(File.join('.gitignore.erb'), '.gitignore', {})
    end

    def self.install_isomorfeus_entries
      data_hash = { app_class:          app_class }
      create_file_from_template('isomorfeus_loader.rb.erb', File.join(isomorfeus_path, 'isomorfeus_loader.rb'), data_hash)
      create_file_from_template('isomorfeus_web_worker_loader.rb.erb', File.join(isomorfeus_path, 'isomorfeus_web_worker_loader.rb'), data_hash)
      create_file_from_template('mail_components_loader.rb.erb', File.join(isomorfeus_path, 'mail_components_loader.rb'), data_hash)
    end

    def self.install_js_entries
      data_hash = {}
      create_file_from_template('application.js.erb', entrypoint_path('application.js'), data_hash)
      create_file_from_template('application_common.js.erb', entrypoint_path('application_common.js'), data_hash)
      create_file_from_template('application_ssr.js.erb', entrypoint_path('application_ssr.js'), data_hash)
      create_file_from_template('application_web_worker.js.erb', entrypoint_path('application_web_worker.js'), data_hash)
      create_file_from_template('mail_components.js.erb', entrypoint_path('mail_components.js'), data_hash)
    end

    def self.install_styles
      create_file_from_template('application.css.erb', stylesheet_path('application.css'), {})
    end

    def self.install_webpack_config
      File.unlink(webpack_config_path('production.js'), webpack_config_path('development.js'),
                  webpack_config_path('debug.js'))
      create_file_from_template('production.js.erb', webpack_config_path('production.js'), {})
      create_file_from_template('development.js.erb', webpack_config_path('development.js'), {})
      create_file_from_template('development_ssr.js.erb', webpack_config_path('development_ssr.js'), {})
      create_file_from_template('debug.js.erb', webpack_config_path('debug.js'), {})
    end

    def self.create_gemfile
      rack_server_gems = ''
      Isomorfeus::Installer.rack_servers[options[:rack_server]]&.fetch(:gems)&.each do |gem|
        rack_server_gems << generate_gem_line(gem)
      end
      database_gems = ''
      Isomorfeus::Installer.databases[options[:database]]&.fetch(:gems)&.each do |gem|
        database_gems << generate_gem_line(gem)
      end
      data_hash = { database_gems:      database_gems.chop,
                    rack_server_gems:   rack_server_gems.chop }
      if source_dir
        %i[isomorfeus_data isomorfeus_i18n isomorfeus_mailer isomorfeus_operation isomorfeus_policy isomorfeus_transport].each do |i_module|
          data_hash[i_module] = i_module == isomorfeus_module ? "path: '..'" : "path: '../../#{i_module.to_s.tr('_', '-')}'"
        end
        data_hash[:isomorfeus] = nil
      else
        data_hash[:isomorfeus] = "'~> #{Isomorfeus::VERSION}'"
      end
      create_file_from_template('Gemfile.erb', 'Gemfile', data_hash)
    end

    def self.create_components
      data_hash = { app_class: app_class }
      create_file_from_template('my_app.rb.erb',
                                File.join(isomorfeus_path, 'components', app_class.underscore + '.rb'), data_hash)
      create_file_from_template('hello_component.rb.erb',
                                File.join(isomorfeus_path, 'components', 'hello_component.rb'), {})
      create_file_from_template('navigation_links.rb.erb',
                                File.join(isomorfeus_path, 'components', 'navigation_links.rb'), {})
      create_file_from_template('not_found_404_component.rb.erb',
                                File.join(isomorfeus_path, 'components', 'not_found_404_component.rb'), {})
      create_file_from_template('welcome_component.rb.erb',
                                File.join(isomorfeus_path, 'components', 'welcome_component.rb'), {})
    end

    def self.create_middlewares
      "use_isomorfeus_middlewares"
    end

    def self.create_package_json
      data_hash = { application_name: app_class }
      create_file_from_template('package.json.erb', 'package.json', data_hash)
    end

    def self.create_policy
      create_file_from_template('anonymous_policy.rb.erb',
                                File.join(isomorfeus_path, 'policies', 'anonymous_policy.rb'), {})
    end

    def self.create_procfile
      data_hash = { rack_server_start_command: rack_server[:start_command] }
      create_file_from_template('Procfile.erb', 'Procfile', data_hash)
      create_file_from_template('ProcfileDev.erb', 'ProcfileDev', data_hash)
      create_file_from_template('ProcfileDebug.erb', 'ProcfileDebug', data_hash)
    end

    def self.create_spec
      data_hash = { app_class: app_class, app_require: app_require, rack_server: rack_server_name }
      create_file_from_template('spec_helper.rb.erb', File.join('spec', 'spec_helper.rb'), data_hash)
      create_file_from_template('test_spec.rb.erb', File.join('spec', 'test_spec.rb'), {})
    end

    def self.use_asset_bundler?
      options.has_key?('asset_bundler')
    end

    def self.copy_source_dir_files
      Dir.glob("#{source_dir}/**/*").each do |file|
        if File.file?(file)
          target_file = file[(source_dir.size+1)..-1]
          target_dir = File.dirname(target_file)
          Dir.mkdir(target_dir) unless Dir.exist?(target_dir)
          puts "Copying #{file} to #{target_file}."
          FileUtils.copy(file, target_file)
        end
      end
    end
  end
end
