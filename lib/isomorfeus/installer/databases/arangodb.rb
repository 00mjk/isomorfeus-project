module Isomorfeus
  module Installer
    module Databases
      module ArangoDB

      end
    end
  end
end

Isomorfeus::Installer.add_database('arangodb',
                                   gems: [ { name: 'isomorfeus-record', version: "~> #{Isomorfeus::Installer::VERSION}" },
                                           { name: 'isomorfeus-record-arango', version: "~> #{Isomorfeus::Installer::VERSION}" } ],
                                   installer: Isomorfeus::Installer::Databases::ArangoDB)