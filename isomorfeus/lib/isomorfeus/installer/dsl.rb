module Isomorfeus
  module Installer
    module DSL
      def copy_file(from, to)
        puts "Copying #{from} to #{to}."
        FileUtils.copy(from, to)
      end

      def create_directory(directory)
        unless Dir.exist?(directory)
          puts "Creating directory #{directory}."
          FileUtils.mkdir_p(directory)
          FileUtils.touch(File.join(directory, '.keep'))
        end
      end

      def create_file_from_template(templates_path, template_file, target_file_path, data_hash)
        template = ERB.new(File.read(File.join(templates_path, template_file), mode: 'r'))
        result = template.result_with_hash(data_hash)
        ext = File.exist?(target_file_path) ? '_new' : ''
        puts "Generating #{target_file_path + ext}."
        File.write(target_file_path + ext, result, mode: 'w')
      end

      def create_common_framework_directories
        # no created: handlers
        %w[channels components data layouts locales mail_components operations policies server].each do |isomorfeus_dir|
          create_directory(File.join('app', isomorfeus_dir))
        end
        create_directory('storage')
        create_directory('public')
        create_directory('spec')
        create_directory('config')
      end

      def install_basic_components
        data_hash = { app_class: Isomorfeus::Installer.app_class }
        create_file_from_template(Isomorfeus::Installer.templates_path, 'my_app.rb.erb',
                                  File.join('app', 'components', Isomorfeus::Installer.app_class.underscore + '.rb'), data_hash)
        create_file_from_template(Isomorfeus::Installer.templates_path,'hello_component.rb.erb',
                                  File.join('app', 'components', 'hello_component.rb'), {})
        create_file_from_template(Isomorfeus::Installer.templates_path, 'navigation_links.rb.erb',
                                  File.join('app', 'components', 'navigation_links.rb'), {})
        create_file_from_template(Isomorfeus::Installer.templates_path, 'not_found_404_component.rb.erb',
                                  File.join('app', 'components', 'not_found_404_component.rb'), {})
        create_file_from_template(Isomorfeus::Installer.templates_path, 'welcome_component.rb.erb',
                                  File.join('app', 'components', 'welcome_component.rb'), {})
      end

      def install_basic_policy
        create_file_from_template(Isomorfeus::Installer.templates_path, 'anonymous_policy.rb.erb',
                                  File.join('app', 'policies', 'anonymous_policy.rb'), {})
      end

      def install_spec_files
        data_hash = { roda_app_class: Isomorfeus::Installer.roda_app_class, roda_app_path: Isomorfeus::Installer.roda_app_path,
                      rack_server: Isomorfeus::Installer.rack_server_name }
        create_file_from_template(Isomorfeus::Installer.templates_path, 'spec_helper.rb.erb', File.join('spec', 'spec_helper.rb'), data_hash)
        create_file_from_template(Isomorfeus::Installer.templates_path, 'web_spec.rb.erb', File.join('spec', 'web_spec.rb'), {})
      end

      def config_path(config_file)
        File.join( 'config', config_file)
      end
    end
  end
end
