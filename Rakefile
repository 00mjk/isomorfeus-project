require 'bundler/cli'
require 'bundler/cli/exec'

VERSION = File.read('ISOMORFEUS_VERSION').chop
puts "VERSION #{VERSION}"

GEMFILE_DIRS = %w[
  example-apps/all_component_types
  example-apps/basic
  isomorfeus-data
  isomorfeus-data/test_app
  isomorfeus-i18n
  isomorfeus
  isomorfeus-operation
  isomorfeus-operation/test_app
  isomorfeus-policy
  isomorfeus-policy/test_app
  isomorfeus-transport
  isomorfeus-transport/test_app
]

def build_gem_for(isomorfeus_module)
  `gem build isomorfeus-#{isomorfeus_module}.gemspec`
end

def path_for(isomorfeus_module)
  File.join('ruby', "isomorfeus-#{isomorfeus_module}")
end

def run_rake_spec_for(isomorfeus_module)
  pwd = Dir.pwd
  Dir.chdir(path_for(isomorfeus_module))
  system('rake')
  Dir.chdir(pwd)
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

task :push_ruby_packages do
  %w[data i18n operation policy transport].each do |mod|
    system("gem push ruby/isomorfeus-#{mod}/isomorfeus-#{mod}-#{VERSION}.gem")
  end
  system("gem push ruby/isomorfeus/isomorfeus-#{VERSION}.gem")
end

task :build_ruby_packages do
  Rake::Task['build_ruby_data_package'].invoke
  Rake::Task['build_ruby_i18n_package'].invoke
  Rake::Task['build_ruby_installer_package'].invoke
  Rake::Task['build_ruby_operation_package'].invoke
  Rake::Task['build_ruby_policy_package'].invoke
  Rake::Task['build_ruby_transport_package'].invoke
end

task :build_ruby_data_package do
  update_version_and_build_gem_for('data')
end

task :build_ruby_i18n_package do
  update_version_and_build_gem_for('i18n')
end

task :build_ruby_installer_package do
  pwd = Dir.pwd
  Dir.chdir(File.join('ruby', "isomorfeus"))
  File.open("lib/isomorfeus/version.rb", 'rt+') do |f|
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
  `gem build isomorfeus.gemspec`
  Dir.chdir(pwd)
end

task :build_ruby_operation_package do
  update_version_and_build_gem_for('operation')
end

task :build_ruby_policy_package do
  update_version_and_build_gem_for('policy')
end

task :build_ruby_transport_package do
  update_version_and_build_gem_for('transport')
end

task :ruby_specs do
  Rake::Task['ruby_installer_spec'].invoke
  Rake::Task['ruby_data_spec'].invoke
  Rake::Task['ruby_i18n_spec'].invoke
  Rake::Task['ruby_operation_spec'].invoke
  Rake::Task['ruby_policy_spec'].invoke
  Rake::Task['ruby_transport_spec'].invoke
end

task :ruby_data_spec do
  run_rake_spec_for('data')
end

task :ruby_i18n_spec do
  run_rake_spec_for('i18n')
end

task :ruby_installer_spec do
  pwd = Dir.pwd
  Dir.chdir(File.join('ruby', "isomorfeus"))
  system('bundle install')
  options = { keep_file_descriptors: false }
  options.define_singleton_method(:keep_file_descriptors?) do
    false
  end
  pid = fork do
    Bundler::CLI::Exec.new(options, ['rspec']).run
  end
  Process.waitpid(pid)
  Dir.chdir(pwd)
end

task :ruby_operation_spec do
  run_rake_spec_for('operation')
end

task :ruby_policy_spec do
  run_rake_spec_for('policy')
end

task :ruby_transport_spec do
  run_rake_spec_for('transport')
end

task :update_gems do
  pwd = File.expand_path(Dir.pwd)
  GEMFILE_DIRS.each do |dir|
    Dir.chdir("ruby/#{dir}")
    system("bundle update")
    Dir.chdir(pwd)
  end
end
