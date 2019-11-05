module Isomorfeus
  module Installer
    module Databases
      module PostgreSQL
        def self.configuration
          <<~CONFIG
          Isomorfeus.activerecord_connection = {
            adapter: 'postgres',
            database: '#{Installer.project_name}_development',
            username: '#{Installer.project_name}_user',
            password: '#{Installer.project_name}_password',
            host: 'localhost',
            encoding: 'utf8',
            pool: 5
          }
          CONFIG
        end
      end
    end
  end
end

Isomorfeus::Installer.add_database('postgresql',
                                   gems: [ { name: 'postgres', version: '~> 0.8.1' },
                                           { name: 'isomorfeus-record', version: "~> #{Isomorfeus::Installer::VERSION}" },
                                           { name: 'isomorfeus-record-activerecord', version: "~> #{Isomorfeus::Installer::VERSION}" } ],
                                   installer: Isomorfeus::Installer::Databases::PostgreSQL)