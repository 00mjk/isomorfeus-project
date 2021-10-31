require 'spec_helper'

RSpec.describe 'isomorfeus installer' do
  context 'creating a app' do
    before do
      FileUtils.rm_rf('test_app') if Dir.exist?('test_app')
    end

    after do
      Dir.chdir('..') if Dir.pwd.end_with?('test_app')
      FileUtils.rm_rf('test_app') if Dir.exist?('test_app')
    end

    it 'it can' do
      Isomorfeus::CLI.start(%w[new test_app -y no])
      Dir.chdir('test_app')
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
      expect(File.exist?(File.join('app', 'components', 'test_app_app.rb'))).to be true
      expect(File.exist?(File.join('app', 'components', 'navigation_links.rb'))).to be true
      expect(File.exist?(File.join('app', 'components', 'not_found_404_component.rb'))).to be true
      expect(File.exist?(File.join('app', 'layouts', 'web.mustache'))).to be true
      expect(File.exist?(File.join('app', 'layouts', 'mail_preview.mustache'))).to be true
      expect(File.exist?(File.join('app', 'policies', 'anonymous_policy.rb'))).to be true
      expect(File.exist?(File.join('app', 'server', 'test_app_roda_app.rb'))).to be true
      expect(File.exist?(File.join('app', 'isomorfeus_loader.rb'))).to be true
      expect(File.exist?(File.join('app', 'mail_loader.rb'))).to be true
      expect(File.exist?(File.join('config', 'iodine.rb'))).to be true
      expect(Dir.exist?(File.join('public'))).to be true
      expect(File.exist?('app_loader.rb')).to be true
      expect(File.exist?('config.ru')).to be true
      expect(File.exist?('Gemfile')).to be true
      expect(File.exist?('.gitignore')).to be true
    end

    it 'with the cmd it can' do
      system('bundle exec isomorfeus new test_app -y no')
      Dir.chdir('test_app')
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
      expect(File.exist?(File.join('app', 'components', 'test_app_app.rb'))).to be true
      expect(File.exist?(File.join('app', 'components', 'navigation_links.rb'))).to be true
      expect(File.exist?(File.join('app', 'components', 'not_found_404_component.rb'))).to be true
      expect(File.exist?(File.join('app', 'layouts', 'web.mustache'))).to be true
      expect(File.exist?(File.join('app', 'layouts', 'mail_preview.mustache'))).to be true
      expect(File.exist?(File.join('app', 'policies', 'anonymous_policy.rb'))).to be true
      expect(File.exist?(File.join('app', 'server', 'test_app_roda_app.rb'))).to be true
      expect(File.exist?(File.join('app', 'isomorfeus_loader.rb'))).to be true
      expect(File.exist?(File.join('app', 'mail_loader.rb'))).to be true
      expect(File.exist?(File.join('config', 'iodine.rb'))).to be true
      expect(File.exist?('app_loader.rb')).to be true
      expect(File.exist?('config.ru')).to be true
      expect(File.exist?('Gemfile')).to be true
      expect(File.exist?('.gitignore')).to be true
    end
  end

  context 'in a new app' do
    before :all do
      FileUtils.rm_rf('test_app') if Dir.exist?('test_app')
      Isomorfeus::CLI.start(%w[new test_app -y no])
      Dir.chdir('test_app')
      Bundler.with_unbundled_env do
        system('bundle install')
      end
    end

    after :all do
      Dir.chdir('..') if Dir.pwd.end_with?('test_app')
      FileUtils.rm_rf('test_app') if Dir.exist?('test_app')
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
      FileUtils.rm_rf('test_app') if Dir.exist?('test_app')
    end

    after do
      Dir.chdir('..') if Dir.pwd.end_with?('test_app')
      FileUtils.rm_rf('test_app') if Dir.exist?('test_app')
    end

    it 'iodine' do
      Isomorfeus::CLI.start(%w[new test_app -r iodine -y no])
      Dir.chdir('test_app')
      expect(File.exist?(File.join('config', 'iodine.rb'))).to be true

      test_result = Bundler.with_unbundled_env do
        system('bundle install')
        `bundle exec rspec`
      end
      expect(test_result).to include('1 example, 0 failures')
    end
  end
end
