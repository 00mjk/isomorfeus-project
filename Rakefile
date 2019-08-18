task default: %w[run_test_app_specs]

task :run_test_app_specs do
  system('rm -rf test_app')
  system('../isomorfeus-installer/bin/isomorfeus test_app -m i18n -s test_app_files')
  pwd = File.expand_path(Dir.pwd)
  Dir.chdir('test_app')
  system('env -i PATH=$PATH bundle exec rspec')
  Dir.chdir(pwd)
  system('rm -rf test_app')
end
