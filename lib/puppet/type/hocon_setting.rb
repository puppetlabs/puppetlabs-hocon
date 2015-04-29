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
          # Puppet stringifies numerics in versions of Puppet < 4.0.0
          # Account for this in the type
          begin
            numeric_as_string = Integer(value)
          rescue ArgumentError
            numeric_as_string = false
          end
          unless (value.is_a?(Numeric) or numeric_as_string)
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

    munge do |value|
      if value.is_a?(String) and @resource[:type] == 'number'
        value = Integer(value)
      end
      value
    end
  end

  validate do
    message = ""
    if self.original_parameters[:path].nil?
      message += "path is a required parameter. "
    end
    if self.original_parameters[:setting].nil?
      message += "setting is a required parameter. "
    end
    if self.original_parameters[:value].nil? && self[:ensure] != :absent
      message += "value is a required parameter unless ensuring a setting is absent."
    end
    if message != ""
      raise(Puppet::Error, message)
    end
  end
end
