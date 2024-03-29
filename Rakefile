require 'bundler'
require 'bundler/cli'
require 'bundler/cli/exec'
require 'fileutils'

VERSION = File.read('ISOMORFEUS_VERSION').strip
puts "VERSION #{VERSION}"

GEMFILE_DIRS = %w[
  isomorfeus
  isomorfeus-data
  isomorfeus-i18n
  isomorfeus-mailer
  isomorfeus-operation
  isomorfeus-policy
  isomorfeus-transport
]

def build_gem_for(isomorfeus_module)
  `gem build isomorfeus-#{isomorfeus_module}.gemspec`
end

def path_for(isomorfeus_module)
  return "isomorfeus" if isomorfeus_module == "isomorfeus"
  "isomorfeus-#{isomorfeus_module}"
end

def run_rake_spec_for(isomorfeus_module)
  pwd = Dir.pwd
  Dir.chdir(path_for(isomorfeus_module))
  success = system('rake')
  Dir.chdir(pwd)
  raise unless success
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

task :push_packages do
  Rake::Task['push_packages_to_rubygems'].invoke
  Rake::Task['push_packages_to_github'].invoke
end

task :push_packages_to_rubygems do
  %w[data i18n mailer operation policy transport].each do |mod|
    puts "Publishing to rubygems"
    system("gem push isomorfeus-#{mod}/isomorfeus-#{mod}-#{VERSION}.gem")
  end
  system("gem push isomorfeus/isomorfeus-#{VERSION}.gem")
end

task :push_packages_to_github do
  puts "Publishing to github"
  %w[data i18n mailer operation policy transport].each do |mod|
    system("gem push --key github --host https://rubygems.pkg.github.com/isomorfeus isomorfeus-#{mod}/isomorfeus-#{mod}-#{VERSION}.gem")
  end
  system("gem push --key github --host https://rubygems.pkg.github.com/isomorfeus isomorfeus/isomorfeus-#{VERSION}.gem")
end

task :build_packages do
  Rake::Task['build_installer_package'].invoke
  Rake::Task['build_data_package'].invoke
  Rake::Task['build_i18n_package'].invoke
  Rake::Task['build_mailer_package'].invoke
  Rake::Task['build_operation_package'].invoke
  Rake::Task['build_policy_package'].invoke
  Rake::Task['build_transport_package'].invoke
end

task :build_data_package do
  update_version_and_build_gem_for('data')
end

task :build_i18n_package do
  update_version_and_build_gem_for('i18n')
end

task :build_installer_package do
  pwd = Dir.pwd
  Dir.chdir(File.join("isomorfeus"))
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

task :build_mailer_package do
  update_version_and_build_gem_for('mailer')
end

task :build_operation_package do
  update_version_and_build_gem_for('operation')
end

task :build_policy_package do
  update_version_and_build_gem_for('policy')
end

task :build_transport_package do
  update_version_and_build_gem_for('transport')
end

task :specs do
  Rake::Task['installer_spec'].invoke
  Rake::Task['data_spec'].invoke
  Rake::Task['i18n_spec'].invoke
  Rake::Task['mailer_spec'].invoke
  Rake::Task['operation_spec'].invoke
  Rake::Task['policy_spec'].invoke
  Rake::Task['transport_spec'].invoke
end

task :data_spec do
  run_rake_spec_for('data')
end

task :i18n_spec do
  run_rake_spec_for('i18n')
end

task :installer_spec do
  run_rake_spec_for('isomorfeus')
end

task :mailer_spec do
  run_rake_spec_for('mailer')
end

task :operation_spec do
  run_rake_spec_for('operation')
end

task :policy_spec do
  run_rake_spec_for('policy')
end

task :transport_spec do
  run_rake_spec_for('transport')
end

task :update_gems do
  pwd = File.expand_path(Dir.pwd)
  GEMFILE_DIRS.each do |dir|
    Dir.chdir(dir)
    system("bundle update")
    Dir.chdir(pwd)
  end
end

task :push do
  system("git push github")
  system("git push gitlab")
  system("git push bitbucket")
  system("git push gitprep")
end

task default: :specs
