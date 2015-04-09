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
      case @resource[:type]
        when nil
          if @shouldorig.is_a?(Array) and @shouldorig.size > 1
            @resource[:type] = 'array'
          else
            case val.class.to_s.downcase.to_sym
              when :trueclass, :falseclass
                @resource[:type] = 'boolean'
              else
                @resource[:type] = 'string'
            end
          end
        when 'hash', 'array', 'text'
          # we're just leaving these values alone
        else
          if @shouldorig.is_a?(Array) and @shouldorig.size > 1
            raise "Array provided, but type specified as #{@resource[:type]}"
          end
      end
    end
  end


end
