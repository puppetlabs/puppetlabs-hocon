require 'hocon'
require 'hocon/config_render_options'

module Puppet
  module Util
    class ConfigSaver
      def self.save(path, conf)
        File.open(path, 'w+') do |fh|
          config_string = conf.root.render(Hocon::ConfigRenderOptions.new(false, true, true, false))
          fh.puts(config_string)
        end
      end
    end
  end
end