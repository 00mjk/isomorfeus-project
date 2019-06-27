require 'bundler/cli'
require 'bundler/cli/exec'

VERSION = File.read('ISOMORFEUS_VERSION').chop
puts "VERSION #{VERSION}"

def build_gem_for(isomorfeus_module)
  `gem build isomorfeus-#{isomorfeus_module}.gemspec`
end

def path_for(isomorfeus_module)
  File.join('ruby', "isomorfeus-#{isomorfeus_module}")
end

def update_version_and_build_gem_for(isomorfeus_module)
  pwd = Dir.pwd
  Dir.chdir(path_for(isomorfeus_module))
  update_version_for(isomorfeus_module)
  build_gem_for(isomorfeus_module)
  Dir.chdir(pwd)
end

def update_version_for(isomorfeus_module)
  File.open("lib/isomorfeus/#{isomorfeus_module}/version.rb", 'rt+') do |f|
    out = ''
    f.each_line do |line|
      if /\sVERSION/.match?(line)
        out << line.sub(/VERSION = ['"][\w.-]+['"]/, "VERSION = '#{VERSION}'" )
      else
        out << line
      end
    end
    f.truncate(0)
    f.pos = 0
    f.write(out)
  end
end

task default: %w[ruby_specs]

task :build_packages do
  Rake::Task['build_ruby_installer_package'].invoke
  Rake::Task['build_ruby_transport_package'].invoke
end

task :build_ruby_installer_package do
  update_version_and_build_gem_for('installer')
end

task :build_ruby_transport_package do
  update_version_and_build_gem_for('installer')
end

task :ruby_specs do
  Rake::Task['ruby_installer_spec'].invoke
  Rake::Task['ruby_transport_spec'].invoke
end

task :ruby_installer_spec do
  pwd = Dir.pwd
  Dir.chdir(path_for('installer'))
  system('bundle install')
  options = { keep_file_descriptors: false }
  options.define_singleton_method(:keep_file_descriptors?) do
    false
  end
  Bundler::CLI::Exec.new(options, ['rspec']).run
  Dir.chdir(pwd)
end

task :ruby_transport_spec do
  pwd = Dir.pwd
  Dir.chdir(path_for('transport'))
  Dir.chdir('test_app')
  system('yarn install')
  system('bundle install')
  options = { keep_file_descriptors: false }
  options.define_singleton_method(:keep_file_descriptors?) do
    false
  end
  Bundler::CLI::Exec.new(options, ['rspec']).run
  Dir.chdir(pwd)
end