require 'puppet/util/feature'
if Puppet.features.hocon?
  require 'hocon/config_factory'
  require 'hocon/parser/config_document_factory'
  require 'hocon/config_value_factory'
end

require File.expand_path('../../../util/config_saver', __FILE__)

Puppet::Type.type(:hocon_setting).provide(:ruby) do
  def self.namevar(section_name, setting)
    "#{setting}"
  end

  def exists?
    conf_file.has_value?(setting)
  end

  def create
    conf_file_modified = set_value(resource[:value])
    Puppet::Util::ConfigSaver.save(resource[:path], conf_file_modified)
    @conf_file = nil
  end

  def destroy
    conf_file_modified = conf_file.remove_value(setting)
    Puppet::Util::ConfigSaver.save(resource[:path], conf_file_modified)
    @conf_file = nil
  end

  def value
    conf_object.get_value(setting).unwrapped
  end

  def value=(value)
    conf_file_modified = set_value(value)
    Puppet::Util::ConfigSaver.save(resource[:path], conf_file_modified)
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

  def conf_object
    if @conf_file.nil? && (not File.exist?(file_path))
      File.new(file_path, "w")
    end
    Hocon::ConfigFactory.parse_file(file_path)
  end

  def set_value(value)
    if resource[:type] == 'array' || (value.is_a?(String) && resource[:type] != 'text') || (value.is_a?(Array) && value.size > 1)
      value = Hocon::ConfigValueFactory.from_any_ref(value, nil)
    elsif resource[:type] == 'text'
      value = value[0]
    else
      value = Hocon::ConfigValueFactory.from_any_ref(value[0], nil)
    end

    if resource[:type] == 'text'
      conf_file_modified = conf_file.set_value(setting, value)
    else
      conf_file_modified = conf_file.set_config_value(setting, value)
    end

    conf_file_modified
  end
end
