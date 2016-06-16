#
# create.conf_settings.rb
#

module Puppet::Parser::Functions
  newfunction(:create_hocon_settings, :type => :statement, :doc => <<-EOS
Uses create_resources to create a set of hocon_setting resources from a hash:

    $settings = {
      foo.bar => {
        baz => 'foobarbaz'
      },
      one.two => {
        three1 => {
          value => 'one-two-three.1',
          type  => 'string',
        },
        three2 => {
          ensure => absent
        }
      }
    }
    $defaults = {
      path => '/tmp/foo.conf'
    }
    create_hocon_settings($settings,$defaults)


Will create the following resources

    hocon_setting{'/tmp/foo.conf foo.bar.baz':
      ensure  => present,
      setting => 'foo.bar.baz',
      value   => 'foobarbaz',
      path    => '/tmp/foo.conf',
    }
    hocon_setting{'/tmp/foo.conf one.two.three1':
      ensure  => present,
      setting => 'one.two.three1',
      value   => 'one-two-three.1',
      path    => '/tmp/foo.conf',
    }
    hocon_setting{'/tmp/foo.conf one.two.three2':
      ensure  => absent,
      setting => 'one.two.three2',
      path    => '/tmp/foo.conf',
    }

  EOS
  ) do |arguments|

    raise(Puppet::ParseError, "create_hocon_settings(): Wrong number of arguments " +
        "given (#{arguments.size} for 1 or 2)") unless arguments.size.between?(1,2)

    settings = arguments[0]
    defaults = arguments[1] || {}

    if [settings,defaults].any?{|i| !i.is_a?(Hash) }
      raise(Puppet::ParseError,
            'create_hocon_settings(): Requires all arguments to be a Hash')
    end

    resources = settings.keys.inject({}) do |res, parent_setting|
      raise(Puppet::ParseError,
            "create.conf_settings(): Settings for '#{parent_setting}' must contain a Hash") \
        unless settings[parent_setting].is_a?(Hash)

      unless path = defaults.merge(settings)['path']
        raise Puppet::ParseError, 'create_hocon_settings(): must pass the path parameter to the Hocon_setting resource!'
      end

      settings[parent_setting].each do |setting, value|
        res["#{path} #{parent_setting}.#{setting}"] = {
            'ensure'  => 'present',
            'setting' => "#{parent_setting}.#{setting}",
        }.merge(if value.is_a?(Hash)
                  value
                else
                  { 'value'   => value, }
                end)
      end
      res
    end

    Puppet::Parser::Functions.function('create_resources')
    function_create_resources(['hocon_setting',resources,defaults])
  end
end

# vim: set ts=2 sw=2 et :
