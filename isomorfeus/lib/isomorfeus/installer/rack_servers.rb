Isomorfeus::Installer.add_rack_server('isomorfeus-iodine', {
  gems: [ { name: 'isomorfeus-iodine', version: "~> 0.7.45", require: true } ],
  start_command: 'bundle exec iodine',
  config_template: 'iodine.rb.erb'
})
