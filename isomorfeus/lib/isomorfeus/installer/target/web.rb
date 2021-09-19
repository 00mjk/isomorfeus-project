module Isomorfeus
  module Installer
    module Target
      class Web
        extend Isomorfeus::Installer::DSL

        class << self
          def execute
            install_roda_app
            install_configuration
            install_web_loaders
            install_web_layouts
            install_web_specs unless Isomorfeus::Installer.project_name == 'test_app'
          end

          # DSL

          def install_roda_app
            data_hash = { roda_app_class: Isomorfeus::Installer.roda_app_class, app_class: Isomorfeus::Installer.app_class }
            create_file_from_template(templates_path, 'roda_app.rb.erb', File.join('app', 'server', Isomorfeus::Installer.roda_app_path + '.rb'), data_hash)
            data_hash = { roda_app_class: Isomorfeus::Installer.roda_app_class, roda_app_path: Isomorfeus::Installer.roda_app_path }
            create_file_from_template(templates_path, 'config.ru.erb', 'config.ru', data_hash)
            create_file_from_template(templates_path, File.join('app_loader.rb.erb'), 'app_loader.rb', {})
            create_file_from_template(templates_path, File.join('.gitignore.erb'), '.gitignore', {})
          end

          def install_configuration
            create_file_from_template(templates_path, Isomorfeus::Installer.rack_server[:config_template], config_path(Isomorfeus::Installer.rack_server[:config_template][0..-5]), {})
            data_hash = { app_class: Isomorfeus::Installer.app_class }
          end

          def install_web_layouts
            copy_file(File.join(templates_path, 'web.mustache.erb'), File.join('app', 'layouts', 'web.mustache'))
            copy_file(File.join(templates_path, 'mail_preview.mustache.erb'), File.join('app', 'layouts', 'mail_preview.mustache'))
          end

          def install_web_loaders
            create_file_from_template(templates_path, 'isomorfeus_loader.rb.erb', File.join('app', 'isomorfeus_loader.rb'), {})
            # create_file_from_template(templates_path, 'web_worker_loader.rb.erb', File.join('app', 'web_worker_loader.rb'), {})
            create_file_from_template(templates_path, 'mail_loader.rb.erb', File.join('app', 'mail_loader.rb'), {})
          end

          def install_web_specs
            create_file_from_template(templates_path, 'web_spec.rb.erb', File.join('spec', 'web_spec.rb'), {})
          end

          def templates_path
            Isomorfeus::Installer.templates_path
          end
        end
      end
    end
  end
end
