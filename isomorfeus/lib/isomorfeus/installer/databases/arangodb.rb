module Isomorfeus
  module Installer
    module Databases
      module ArangoDB

      end
    end
  end
end

Isomorfeus::Installer.add_database('arangodb',
                                   gems: [ { name: 'arango-driver', version: "~> 3.5.0.alpha0" } ],
                                   installer: Isomorfeus::Installer::Databases::ArangoDB)
