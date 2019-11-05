module Isomorfeus
  module Installer
    module Databases
      module Neo4j
        def self.configuration
          "Isomorfeus.neo4j_connection_uri = 'http://neo4j:neo4j@localhost:7474'"
        end
      end
    end
  end
end

Isomorfeus::Installer.add_database('neo4j',
                                   gems: [ { name: 'isomorfeus-record', version: "~> #{Isomorfeus::Installer::VERSION}" },
                                           { name: 'isomorfeus-record-neo4j', version: "~> #{Isomorfeus::Installer::VERSION}" } ],
                                   installer: Isomorfeus::Installer::Databases::Neo4j)