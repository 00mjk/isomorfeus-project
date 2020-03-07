module Isomorfeus
  module Installer
    module Target
      class Web
        extend Isomorfeus::Installer::DSL

        class << self
          def execute
            install_roda_app
            install_configuration

            OpalWebpackLoader::Installer::CLI.start(['iso'])
            install_webpack_config

            install_web_styles
            install_web_imports
            install_web_loaders
            install_web_layouts

            install_web_specs

            install_procfiles
          end

          # DSL

          def install_roda_app
            data_hash = { roda_app_class: Isomorfeus::Installer.roda_app_class, app_class: Isomorfeus::Installer.app_class }
            create_file_from_template(templates_path, 'roda_app.rb.erb', Isomorfeus::Installer.roda_app_path + '.rb', data_hash)
            data_hash = { roda_app_class: Isomorfeus::Installer.roda_app_class, roda_app_path: Isomorfeus::Installer.roda_app_path }
            create_file_from_template(templates_path, 'config.ru.erb', 'config.ru', data_hash)
            create_file_from_template(templates_path, File.join('app_loader.rb.erb'), 'app_loader.rb', {})
            create_file_from_template(templates_path, File.join('.gitignore.erb'), '.gitignore', {})
          end

          def install_configuration
            create_file_from_template(templates_path, Isomorfeus::Installer.rack_server[:config_template], config_path(Isomorfeus::Installer.rack_server[:config_template][0..-5]), {})
            data_hash = { app_class: Isomorfeus::Installer.app_class }
            create_file_from_template(templates_path, 'arango_config.rb.erb', config_path('arango.rb'), data_hash)
          end

          def install_procfiles
            data_hash = { rack_server_start_command: Isomorfeus::Installer.rack_server[:start_command] }
            create_file_from_template(templates_path, 'Procfile.erb', 'Procfile', data_hash)
            create_file_from_template(templates_path, 'ProcfileDev.erb', 'ProcfileDev', data_hash)
            create_file_from_template(templates_path, 'ProcfileDebug.erb', 'ProcfileDebug', data_hash)
          end

          def install_web_imports
            create_file_from_template(templates_path, 'web.js.erb', js_import_path('web.js'), {})
            create_file_from_template(templates_path, 'web_common.js.erb', js_import_path('web_common.js'), {})
            create_file_from_template(templates_path, 'web_ssr.js.erb', js_import_path('web_ssr.js'), {})
            # create_file_from_template(templates_path, 'web_worker.js.erb', js_import_path('web_worker.js'), data_hash)
            create_file_from_template(templates_path, 'mail_components.js.erb', js_import_path('mail_components.js'), {})
          end

          def install_web_layouts
            copy_file(File.join(templates_path, 'web.html.erb'), File.join('app', 'layouts', 'web.erb'))
            copy_file(File.join(templates_path, 'mail_preview.html.erb'), File.join('app', 'layouts', 'mail_preview.erb'))
          end

          def install_web_loaders
            create_file_from_template(templates_path, 'web_loader.rb.erb', File.join('app', 'web_loader.rb'), {})
            # create_file_from_template(templates_path, 'web_worker_loader.rb.erb', File.join('app', 'web_worker_loader.rb'), {})
            create_file_from_template(templates_path, 'mail_components_loader.rb.erb', File.join('app', 'mail_components_loader.rb'), {})
          end

          def install_web_specs
            create_file_from_template(templates_path, 'web_spec.rb.erb', File.join('spec', 'web_spec.rb'), {})
          end

          def install_web_styles
            create_file_from_template(templates_path, 'web.css.erb', File.join('app', 'styles', 'web.css'), {})
          end

          def install_webpack_config
            File.unlink(webpack_config_path('production.js'), webpack_config_path('development.js'),
                        webpack_config_path('debug.js'))
            create_file_from_template(templates_path, 'production.js.erb', webpack_config_path('production.js'), {})
            create_file_from_template(templates_path, 'development.js.erb', webpack_config_path('development.js'), {})
            create_file_from_template(templates_path, 'development_ssr.js.erb', webpack_config_path('development_ssr.js'), {})
            create_file_from_template(templates_path, 'debug.js.erb', webpack_config_path('debug.js'), {})
          end

          def templates_path
            Isomorfeus::Installer.templates_path
          end
        end
      end
    end
  end
end

