require 'puppet/util/feature'
if Puppet.features.hocon?
  require 'hocon/config_factory'
  require 'hocon/parser/config_document_factory'
  require 'hocon/config_value_factory'
end

Puppet::Functions.create_function(:"hocon::resources_from_template") do

  dispatch :create do
    required_param 'Enum["present", "absent"]', :ensure
    required_param 'String',                    :path
    required_param 'String',                    :content
    optional_param 'Hash[Scalar, Any]',         :defaults
  end

  def create(x_ensure, path, content, defaults = {})
    hocon_hash = Hocon.parse(content)
    resources = hash_to_properties(hocon_hash).inject({}) do |hash,elem|
      hash.merge("#{path} #{elem[:key]}" => defaults.merge({
        'ensure'  => x_ensure,
        'path'    => path,
        'setting' => elem[:key],
        'value'   => elem[:value]
      }))
    end
    call_function(:create_resources, 'hocon_setting', resources)
  end

  def hash_to_properties(value, key = '')
    return [{:value => value}] unless value.is_a?(Hash)
    result = Array.new
    value.each do |k,v|
      result << hash_to_properties(v,k).map do |elem|
        # k = conv_to_s(k)
        elem[:key] = elem[:key] ? "#{k}.#{elem[:key]}" : k
        elem
      end
    end
    result.flatten
  end

end
