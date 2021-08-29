module Isomorfeus
  class Console
    def initialize
      config_ru = File.read('config.ru')
      config_ru.each_line do |line|
        if line.start_with?('require_relative')
          file = line[17..-1].rstrip.tr('"','').tr("'",'')
          file = file + '.rb' unless file.end_with?('.rb')
          require File.join(Dir.pwd, file)
        end
      end
      Isomorfeus.zeitwerk.enable_reloading
      Isomorfeus.zeitwerk.setup
      Isomorfeus.zeitwerk.eager_load
    end

    def run
      Isomorfeus.pry
    end
  end
end
