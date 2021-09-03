module Isomorfeus
  module Installer
    class InstallTargets
      class << self
        def execute
          targets_string = Isomorfeus::Installer.options[:targets]
          targets_string = 'web' if targets_string == 'all'
          targets = targets_string.split(' ')
          targets = targets_string.split(',') if targets.empty?
          targets = targets_string.split(', ') if targets.empty?

          # install web first
          targets.unshift(targets.delete('web')) if targets.include?('web')

          targets.each do |target|
            target = target.camelize
            if Isomorfeus::Installer::Target.const_defined?(target, false)

              target_class = Isomorfeus::Installer::Target.const_get(target)
              target_class.execute
            else
              raise "No such target #{target} available. Is Isomorfeus Professional installed?"
            end
          end
        end
      end
    end
  end
end
