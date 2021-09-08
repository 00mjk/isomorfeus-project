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
      Isomorfeus::CLI.start(%w[new morphing -y no])
      Dir.chdir('morphing')
      expect(Dir.exist?('config')).to be true
      expect(Dir.exist?(File.join('app', 'channels'))).to be true
      expect(Dir.exist?(File.join('app', 'components'))).to be true
      expect(Dir.exist?(File.join('app', 'data'))).to be true
      # expect(Dir.exist?(File.join('app', 'handlers'))).to be true
      expect(Dir.exist?(File.join('app', 'layouts'))).to be true
      expect(Dir.exist?(File.join('app', 'locales'))).to be true
      expect(Dir.exist?(File.join('app', 'mail_components'))).to be true
      expect(Dir.exist?(File.join('app', 'operations'))).to be true
      expect(Dir.exist?(File.join('app', 'policies'))).to be true
      expect(File.exist?(File.join('app', 'components', 'welcome_component.rb'))).to be true
      expect(File.exist?(File.join('app', 'components', 'hello_component.rb'))).to be true
      expect(File.exist?(File.join('app', 'components', 'morphing_app.rb'))).to be true
      expect(File.exist?(File.join('app', 'components', 'navigation_links.rb'))).to be true
      expect(File.exist?(File.join('app', 'components', 'not_found_404_component.rb'))).to be true
      expect(File.exist?(File.join('app', 'layouts', 'web.erb'))).to be true
      expect(File.exist?(File.join('app', 'layouts', 'mail_preview.erb'))).to be true
      expect(File.exist?(File.join('app', 'policies', 'anonymous_policy.rb'))).to be true
      expect(File.exist?(File.join('app', 'server', 'morphing_roda_app.rb'))).to be true
      expect(File.exist?(File.join('app', 'isomorfeus_loader.rb'))).to be true
      expect(File.exist?(File.join('app', 'mail_components_loader.rb'))).to be true
      expect(File.exist?(File.join('config', 'iodine.rb'))).to be true
      expect(Dir.exist?(File.join('public'))).to be true
      expect(File.exist?('app_loader.rb')).to be true
      expect(File.exist?('config.ru')).to be true
      expect(File.exist?('Gemfile')).to be true
      expect(File.exist?('.gitignore')).to be true
    end

    it 'with the cmd it can' do
      system('bundle exec isomorfeus new morphing -y no')
      Dir.chdir('morphing')
      expect(Dir.exist?('config')).to be true
      expect(Dir.exist?(File.join('app', 'channels'))).to be true
      expect(Dir.exist?(File.join('app', 'components'))).to be true
      expect(Dir.exist?(File.join('app', 'data'))).to be true
      # expect(Dir.exist?(File.join('app', 'handlers'))).to be true
      expect(Dir.exist?(File.join('app', 'layouts'))).to be true
      expect(Dir.exist?(File.join('app', 'locales'))).to be true
      expect(Dir.exist?(File.join('app', 'mail_components'))).to be true
      expect(Dir.exist?(File.join('app', 'operations'))).to be true
      expect(Dir.exist?(File.join('app', 'policies'))).to be true
      expect(File.exist?(File.join('app', 'components', 'welcome_component.rb'))).to be true
      expect(File.exist?(File.join('app', 'components', 'hello_component.rb'))).to be true
      expect(File.exist?(File.join('app', 'components', 'morphing_app.rb'))).to be true
      expect(File.exist?(File.join('app', 'components', 'navigation_links.rb'))).to be true
      expect(File.exist?(File.join('app', 'components', 'not_found_404_component.rb'))).to be true
      expect(File.exist?(File.join('app', 'layouts', 'web.erb'))).to be true
      expect(File.exist?(File.join('app', 'layouts', 'mail_preview.erb'))).to be true
      expect(File.exist?(File.join('app', 'policies', 'anonymous_policy.rb'))).to be true
      expect(File.exist?(File.join('app', 'server', 'morphing_roda_app.rb'))).to be true
      expect(File.exist?(File.join('app', 'isomorfeus_loader.rb'))).to be true
      expect(File.exist?(File.join('app', 'mail_components_loader.rb'))).to be true
      expect(File.exist?(File.join('config', 'iodine.rb'))).to be true
      expect(File.exist?('app_loader.rb')).to be true
      expect(File.exist?('config.ru')).to be true
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
      Isomorfeus::CLI.start(%w[new morphing -y no])
      Dir.chdir('morphing')
      gemfile = File.read('Gemfile')
      new_gemfile_lines = []
      gemfile.lines.each do |line|
        if (line.start_with?("gem 'isomorfeus-") || line.start_with?("  gem 'isomorfeus-")) && line.include?(Isomorfeus::VERSION)
          new_line_items = line.split(',')
          gem_name = line.split("'")[1]
          new_line_items[1] = "path: '../../../../#{gem_name}'"
          new_gemfile_lines << new_line_items.join(', ')
        elsif (line.start_with?("gem 'isomorfeus'") || line.start_with?("  gem 'isomorfeus'")) && line.include?(Isomorfeus::VERSION)
          new_line_items = line.split(',')
          gem_name = line.split("'")[1]
          new_line_items[1] = "path: '../../../../#{gem_name}'"
          new_gemfile_lines << new_line_items.join(', ')
        else
          new_gemfile_lines << line
        end
      end
      File.write('Gemfile', new_gemfile_lines.join(""))
      Bundler.with_unbundled_env do
        system('bundle install')
      end
    end

    after :all do
      Dir.chdir('..') if Dir.pwd.end_with?('morphing')
      FileUtils.rm_rf('morphing') if Dir.exist?('morphing')
      Dir.chdir('..')
      Dir.chdir('..')
    end

    it 'can execute tests' do
      test_result = Bundler.with_unbundled_env do
        `bundle exec rspec`
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

    it 'iodine' do
      Isomorfeus::CLI.start(%w[new morphing -r iodine -y no])
      Dir.chdir('morphing')
      expect(File.exist?(File.join('config', 'iodine.rb'))).to be true
      gemfile = File.read('Gemfile')
      new_gemfile_lines = []
      gemfile.lines.each do |line|
        if (line.start_with?("gem 'isomorfeus-") || line.start_with?("  gem 'isomorfeus-")) && line.include?(Isomorfeus::VERSION)
          new_line_items = line.split(',')
          gem_name = line.split("'")[1]
          new_line_items[1] = "path: '../../../../#{gem_name}'"
          new_gemfile_lines << new_line_items.join(', ')
        elsif (line.start_with?("gem 'isomorfeus'") || line.start_with?("  gem 'isomorfeus'")) && line.include?(Isomorfeus::VERSION)
          new_line_items = line.split(',')
          gem_name = line.split("'")[1]
          new_line_items[1] = "path: '../../../../#{gem_name}'"
          new_gemfile_lines << new_line_items.join(', ')
        else
          new_gemfile_lines << line
        end
      end
      File.write('Gemfile', new_gemfile_lines.join(""))

      test_result = Bundler.with_unbundled_env do
        system('bundle install')
        `bundle exec rspec`
      end
      expect(test_result).to include('1 example, 0 failures')
    end
  end
end
