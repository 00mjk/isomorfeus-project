task default: %w[run_test_app_specs]

task :run_test_app_specs => 'create_test_app' do
  pwd = Dir.pwd
  Dir.chdir('test_app')
  system('env -i PATH=$PATH ARANGO_USER=$ARANGO_USER ARANGO_PASSWORD=$ARANGO_PASSWORD bundle exec rspec')
  Dir.chdir(pwd)
  system('rm -rf test_app')
end

task :create_test_app do
  system('rm -rf test_app')
  system('../isomorfeus-installer/bin/isomorfeus test_app -m operation -s test_app_files')
end

task :start_test_app => 'create_test_app' do
  pwd = Dir.pwd
  Dir.chdir('test_app')
  system('env -i PATH=$PATH foreman start')
  Dir.chdir(pwd)
end
