# Isomorfeus::Installer.add_rack_server('agoo', {
#   gems: [ { name: 'agoo', version: "~> 2.8.3" } ],
#   start_command: 'bundle exec rackup -s agoo'
# })

Isomorfeus::Installer.add_rack_server('iodine', {
  gems: [ { name: 'iodine', version: "~> 0.7.35", require: true } ],
  start_command: 'bundle exec iodine',
  init_template: 'iodine_config.rb.erb',
  rack_server_init: "require_relative 'iodine_config'"
})
