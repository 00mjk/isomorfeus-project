module Isomorfeus
  module Installer
    module Databases
      module SQLite
        def self.configuration
          <<~CONFIG
          Isomorfeus.activerecord_connection = {
            adapter: 'sqlite3',
            database: '#{Installer.project_name}_development.db'
          }
          CONFIG
        end
      end
    end
  end
end

Isomorfeus::Installer.add_database('sqlite',
                                   gems: [ { name: 'sqlite3', version: '~> 1.3.13' },
                                           { name: 'isomorfeus-record', version: "~> #{Isomorfeus::Installer::VERSION}" },
                                           { name: 'isomorfeus-record-activerecord', version: "~> #{Isomorfeus::Installer::VERSION}" } ],
                                   installer: Isomorfeus::Installer::Databases::SQLite)