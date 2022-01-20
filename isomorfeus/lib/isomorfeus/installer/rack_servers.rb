Isomorfeus::Installer.add_rack_server('isomorfeus-iodine', {
  gems: [ { name: 'isomorfeus-iodine', version: "~> 0.7.46", require: true } ],
  config_template: 'iodine.rb.erb'
})
