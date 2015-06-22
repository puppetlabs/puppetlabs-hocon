require 'puppet/util/feature'
if Puppet.features.hocon?
  require 'hocon/config_factory'
  require 'hocon/parser/config_document_factory'
  require 'hocon/config_value_factory'
end

Puppet::Type.type(:hocon_setting).provide(:ruby) do
  def self.namevar(section_name, setting)
    "#{setting}"
  end

  def exists?
    conf_file.has_value?(setting)
  end

  def create
    conf_file_modified = set_value(resource[:value])
    write_conf(conf_file_modified)
    @conf_file = nil
  end

  def destroy
    conf_file_modified = conf_file.remove_value(setting)
    write_conf(conf_file_modified)
    @conf_file = nil
  end

  def type
    @resource[:type]
  end

  def type=(value)
    @resource[:type] = value
  end

  def value
    val = conf_object.get_value(setting).unwrapped

    # This is required because of :array_matching => :all.
    # Without this, Puppet will almost always register changes
    # to a hocon_setting even when it shouldn't.
    unless val.is_a?(Array)
      val = [val]
    end
    val
  end

  def value=(new_value)
    conf_file_modified = set_value(new_value)
    write_conf(conf_file_modified)
    @conf_file = nil
  end

  def setting
    resource[:setting]
  end

  def file_path
    resource[:path]
  end

  private
  def conf_file
    if @conf_file.nil? && (not File.exist?(file_path))
      File.new(file_path, "w")
    end
    @conf_file ||= Hocon::Parser::ConfigDocumentFactory.parse_file(file_path)
  end

  def write_conf(conf)
    File.open(file_path, 'w+') do |fh|
      config_string = conf.render
      fh.puts(config_string)
    end
  end

  def conf_object
    if @conf_file.nil? && (not File.exist?(file_path))
      File.new(file_path, "w")
    end
    Hocon::ConfigFactory.parse_file(file_path)
  end

  def set_value(value_to_set)
    if resource[:type] == 'array' || (value_to_set.is_a?(String) && resource[:type] != 'text') || (value_to_set.is_a?(Array) && value_to_set.size > 1)
      new_value = Hocon::ConfigValueFactory.from_any_ref(value_to_set, nil)
    elsif resource[:type] == 'text'
      new_value = value_to_set[0]
    else
      new_value = Hocon::ConfigValueFactory.from_any_ref(value_to_set[0], nil)
    end

    if resource[:type] == 'text'
      conf_file_modified = conf_file.set_value(setting, new_value)
    else
      conf_file_modified = conf_file.set_config_value(setting, new_value)
    end
    conf_file_modified
  end
end
