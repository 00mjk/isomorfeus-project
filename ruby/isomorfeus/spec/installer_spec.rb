require 'spec_helper'

RSpec.describe 'isomorfeus installer' do
  context 'creating a app' do
    before do
      Dir.chdir('spec')
      Dir.mkdir('test_apps') unless Dir.exist?('test_apps')
      Dir.chdir('test_apps')
      FileUtils.rm_rf('morphing') if Dir.exist?('morphing')
    end

    after do
      Dir.chdir('..') if Dir.pwd.end_with?('morphing')
      FileUtils.rm_rf('morphing') if Dir.exist?('morphing')
      Dir.chdir('..')
      Dir.chdir('..')
    end

    it 'it can' do
      Isomorfeus::Installer::CLI.start(%w[new morphing --no-yarn-and-bundle])
      Dir.chdir('morphing')
      expect(Dir.exist?(File.join('isomorfeus', 'imports')))
      expect(Dir.exist?(File.join('isomorfeus', 'channels')))
      expect(Dir.exist?(File.join('isomorfeus', 'components')))
      expect(Dir.exist?(File.join('isomorfeus', 'data')))
      expect(Dir.exist?(File.join('isomorfeus', 'handlers')))
      expect(Dir.exist?(File.join('isomorfeus', 'locales')))
      expect(Dir.exist?(File.join('isomorfeus', 'operations')))
      expect(Dir.exist?(File.join('isomorfeus', 'policies')))
      expect(Dir.exist?(File.join('isomorfeus', 'styles')))
      expect(File.exist?(File.join('isomorfeus','styles', 'application.css'))).to be true
      expect(File.exist?(File.join('isomorfeus', 'imports', 'application.js'))).to be true
      expect(File.exist?(File.join('isomorfeus', 'imports', 'application_common.js'))).to be true
      expect(File.exist?(File.join('isomorfeus', 'imports', 'application_ssr.js'))).to be true
      expect(File.exist?(File.join('isomorfeus', 'components', 'welcome_component.rb'))).to be true
      expect(File.exist?(File.join('isomorfeus', 'components', 'hello_component.rb'))).to be true
      expect(File.exist?(File.join('isomorfeus', 'components', 'morphing_app.rb'))).to be true
      expect(File.exist?(File.join('isomorfeus', 'components', 'navigation_links.rb'))).to be true
      expect(File.exist?(File.join('isomorfeus', 'components', 'not_found_404_component.rb'))).to be true
      expect(File.exist?(File.join('isomorfeus', 'policies', 'anonymous_policy.rb'))).to be true
      expect(File.exist?(File.join('isomorfeus', 'isomorfeus_loader.rb'))).to be true
      expect(File.exist?(File.join('owl_init.rb'))).to be true
      expect(File.exist?(File.join('app_loader.rb'))).to be true
      expect(File.exist?(File.join('webpack', 'debug.js'))).to be true
      expect(File.exist?(File.join('webpack', 'development.js'))).to be true
      expect(File.exist?(File.join('webpack', 'production.js'))).to be true
      expect(Dir.exist?(File.join('public', 'assets'))).to be true
      expect(File.exist?('package.json')).to be true
      expect(File.exist?('Procfile')).to be true
      expect(File.exist?('ProcfileDebug')).to be true
      expect(File.exist?('config.ru')).to be true
      expect(File.exist?('morphing_app.rb')).to be true
      expect(File.exist?('Gemfile')).to be true
      expect(File.exist?('.gitignore')).to be true
    end

    it 'with the cmd it can' do
      system('bundle exec isomorfeus new morphing --no-yarn-and-bundle')
      Dir.chdir('morphing')
      expect(Dir.exist?(File.join('isomorfeus', 'imports')))
      expect(Dir.exist?(File.join('isomorfeus', 'channels')))
      expect(Dir.exist?(File.join('isomorfeus', 'components')))
      expect(Dir.exist?(File.join('isomorfeus', 'data')))
      expect(Dir.exist?(File.join('isomorfeus', 'handlers')))
      expect(Dir.exist?(File.join('isomorfeus', 'locales')))
      expect(Dir.exist?(File.join('isomorfeus', 'operations')))
      expect(Dir.exist?(File.join('isomorfeus', 'policies')))
      expect(Dir.exist?(File.join('isomorfeus', 'styles')))
      expect(File.exist?(File.join('isomorfeus','styles', 'application.css'))).to be true
      expect(File.exist?(File.join('isomorfeus', 'imports', 'application.js'))).to be true
      expect(File.exist?(File.join('isomorfeus', 'imports', 'application_common.js'))).to be true
      expect(File.exist?(File.join('isomorfeus', 'imports', 'application_ssr.js'))).to be true
      expect(File.exist?(File.join('isomorfeus', 'components', 'welcome_component.rb'))).to be true
      expect(File.exist?(File.join('isomorfeus', 'components', 'hello_component.rb'))).to be true
      expect(File.exist?(File.join('isomorfeus', 'components', 'morphing_app.rb'))).to be true
      expect(File.exist?(File.join('isomorfeus', 'components', 'navigation_links.rb'))).to be true
      expect(File.exist?(File.join('isomorfeus', 'components', 'not_found_404_component.rb'))).to be true
      expect(File.exist?(File.join('isomorfeus', 'policies', 'anonymous_policy.rb'))).to be true
      expect(File.exist?(File.join('isomorfeus', 'isomorfeus_loader.rb'))).to be true
      expect(File.exist?(File.join('owl_init.rb'))).to be true
      expect(File.exist?(File.join('app_loader.rb'))).to be true
      expect(File.exist?(File.join('webpack', 'debug.js'))).to be true
      expect(File.exist?(File.join('webpack', 'development.js'))).to be true
      expect(File.exist?(File.join('webpack', 'production.js'))).to be true
      expect(Dir.exist?(File.join('public', 'assets'))).to be true
      expect(File.exist?('package.json')).to be true
      expect(File.exist?('Procfile')).to be true
      expect(File.exist?('ProcfileDebug')).to be true
      expect(File.exist?('config.ru')).to be true
      expect(File.exist?('morphing_app.rb')).to be true
      expect(File.exist?('Gemfile')).to be true
      expect(File.exist?('.gitignore')).to be true
    end
  end

  context 'in a new app' do
    before :all do
      Dir.chdir('spec')
      Dir.mkdir('test_apps') unless Dir.exist?('test_apps')
      Dir.chdir('test_apps')
      FileUtils.rm_rf('morphing') if Dir.exist?('morphing')
      Isomorfeus::Installer::CLI.start(%w[new morphing --no-yarn-and-bundle])
      Dir.chdir('morphing')
      gemfile = File.read('Gemfile')
      new_gemfile_lines = []
      gemfile.lines.each do |line|
        if (line.start_with?("gem 'isomorfeus-") || line.start_with?("  gem 'isomorfeus-")) && line.include?(Isomorfeus::VERSION)
          new_line_items = line.split(',')
          gem_name = line.split("'")[1]
          new_line_items[1] = "path: '../../../../#{gem_name}'"
          new_gemfile_lines << new_line_items.join(', ')
        else
          new_gemfile_lines << line
        end
      end
      File.write('Gemfile', new_gemfile_lines.join("\n"))
      Bundler.with_original_env do
        system('yarn install')
        system('bundle install')
      end
    end

    after :all do
      Dir.chdir('..') if Dir.pwd.end_with?('morphing')
      FileUtils.rm_rf('morphing') if Dir.exist?('morphing')
      Dir.chdir('..')
      Dir.chdir('..')
    end

    it 'can bundle the assets' do
      Bundler.with_original_env do
        system('yarn run production_build')
      end
      manifest = Oj.load(File.read(File.join('public', 'assets', 'manifest.json')), mode: :strict)
      application_js = manifest['application.js']
      expect(File.exist?(File.join('public', application_js))).to be true
    end

    it 'can execute tests' do
      test_result = Bundler.with_original_env do
        `THREADS=4 WORKERS=1 bundle exec rspec`
      end
      expect(test_result).to include('1 example, 0 failures')
    end
  end

  context 'creating a app with rack server' do
    before do
      Dir.chdir('spec')
      Dir.mkdir('test_apps') unless Dir.exist?('test_apps')
      Dir.chdir('test_apps')
      FileUtils.rm_rf('morphing') if Dir.exist?('morphing')
    end

    after do
      Dir.chdir('..') if Dir.pwd.end_with?('morphing')
      FileUtils.rm_rf('morphing') if Dir.exist?('morphing')
      Dir.chdir('..')
      Dir.chdir('..')
    end

    # it 'agoo' do
    #   Isomorfeus::Installer::CLI.start(%w[new morphing -r agoo --no-yarn-and-bundle])
    #   Dir.chdir('morphing')
    #   system('env -i PATH=$PATH yarn install')
    #   system('env -i PATH=$PATH bundle install')
    #   test_result = `env -i PATH=$PATH ARANGO_USER=$ARANGO_USER ARANGO_PASSWORD=$ARANGO_PASSWORD bundle exec rspec`
    #   expect(test_result).to include('1 example, 0 failures')
    # end

    it 'iodine' do
      Isomorfeus::Installer::CLI.start(%w[new morphing -r iodine --no-yarn-and-bundle])
      Dir.chdir('morphing')
      expect(File.exist?('iodine_config.rb')).to be true
      gemfile = File.read('Gemfile')
      new_gemfile_lines = []
      gemfile.lines.each do |line|
        if (line.start_with?("gem 'isomorfeus-") || line.start_with?("  gem 'isomorfeus-")) && line.include?(Isomorfeus::VERSION)
          new_line_items = line.split(',')
          gem_name = line.split("'")[1]
          new_line_items[1] = "path: '../../../../#{gem_name}'"
          new_gemfile_lines << new_line_items.join(', ')
        else
          new_gemfile_lines << line
        end
      end
      File.write('Gemfile', new_gemfile_lines.join("\n"))

      test_result = Bundler.with_original_env do
        system('yarn install')
        system('bundle install')
        `THREADS=4 WORKERS=1 bundle exec rspec`
      end
      expect(test_result).to include('1 example, 0 failures')
    end
  end
end
