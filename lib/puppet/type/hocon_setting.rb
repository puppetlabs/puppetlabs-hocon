Puppet::Type.newtype(:hocon_setting) do

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:name, :namevar => true) do
    desc 'An arbitrary name used as the identity of the resource.'
  end

  newparam(:setting) do
    desc 'The name of the setting to be defined.'
  end

  newparam(:path) do
    desc 'The file Puppet will ensure contains the specified setting.'
    validate do |value|
      unless (Puppet.features.posix? and value =~ /^\//) or (Puppet.features.microsoft_windows? and (value =~ /^.:\// or value =~ /^\/\/[^\/]+\/[^\/]+/))
        raise(Puppet::Error, "File paths must be fully qualified, not '#{value}'")
      end
    end
  end

  newproperty(:type) do
    desc "The value type"
    # This property has no default. If it is not supplied, the validation of the "value"
    # property will set one automatically.
  end

  newproperty(:value, :array_matching => :all) do
    desc 'The value of the setting to be defined.'

    validate do |val|
      # Grab the value we are going to validate
      value = @shouldorig.is_a?(Array) && (@shouldorig.size > 1 || @resource[:type] == 'array') ? @shouldorig : @shouldorig[0]
      case @resource[:type]
        when 'boolean'
          if value != true && value != false
            raise "Type specified as 'boolean' but was #{value.class}"
          end
        when 'string', 'text'
          unless value.is_a?(String)
            raise "Type specified as #{@resource[:type]} but was #{value.class}"
          end
        when 'number'
          unless value.is_a?(Numeric)
            raise "Type specified as 'number' but was #{value.class}"
          end
        when 'array'
          unless value.is_a?(Array)
            raise "Type specified as 'array' but was #{value.class}"
          end
        when 'hash'
          unless value.is_a?(Hash)
            raise "Type specified as 'hash' but was #{value.class}"
          end
        when nil
          # Do nothing, we'll figure it out on our own
        else
          raise "Type was specified as #{@resource[:type]}, but should have been one of 'boolean', 'string', 'text', 'number', 'array', or 'hash'"
      end
    end
  end
end
