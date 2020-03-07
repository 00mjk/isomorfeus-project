module Isomorfeus
  module Installer
    class InstallTargets
      class << self
        def execute
          targets_string = Isomorfeus::Installer.options[:targets]
          targets = targets_string.split(' ')
          targets = targets_string.split(',') if targets.empty?
          targets = targets_string.split(', ') if targets.empty?

          targets.each do |target|
            target = target.camelize
            if Isomorfeus::Installer::Target.const_defined?(target)
              target_class = Isomorfeus::Installer::Target.const_get(target)
              target_class.execute
            end
          end
        end
      end
    end
  end
end
