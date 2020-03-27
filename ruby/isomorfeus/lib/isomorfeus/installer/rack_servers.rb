Isomorfeus::Installer.add_rack_server('iodine', {
  gems: [ { name: 'iodine', version: "~> 0.7.38", require: true } ],
  start_command: 'bundle exec iodine',
  config_template: 'iodine.rb.erb'
})

Isomorfeus::Installer.add_rack_server('agoo', {
  gems: [ { name: 'iodine', version: "~> 2.12.0", require: true } ],
  start_command: 'bundle exec rackup -s agoo',
  config_template: 'agoo.rb.erb',
})
