# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
Puppet::Type.type(:hocon_setting).provide(:ruby) do
  confine feature: :hocon

  def self.namevar(_section_name, setting)
    setting.to_s
  end

  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def exists?
    return false unless conf_file.has_value?(setting) # rubocop:disable Style/PreferredHashMethods

    type = @resource[:type]
    conf_value = conf_object.get_value(setting).value

    return false if type == 'array' && !conf_value.is_a?(Array)

    return false if type.nil? && conf_value.is_a?(Array) && conf_value.length == 1

    return Array(@resource[:value]).any? { |v| value.flatten.include?(v) } if type == 'array_element'

    true
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  def create
    conf_file_modified = document_with_value(resource[:value])
    write_conf(conf_file_modified)
    @conf_file = nil
  end

  def destroy
    conf_file_modified = remove_value(resource[:value])
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
    val = conf_file.has_value?(setting) ? conf_object.get_value(setting).unwrapped : [] # rubocop:disable Style/PreferredHashMethods
    unless val.is_a?(Array)
      val = if resource[:type] == 'array_element'
              # If the current value of the target setting is not an array,
              # present the current value as an empty array so that an
              # element is added to an empty array (as opposed to converting
              # the current value into the first element in an array and
              # adding the value to set as a second element in the array).
              []
            else
              # This is required because of :array_matching => :all.
              # Without this, Puppet will almost always register changes
              # to a hocon_setting even when it shouldn't.
              [val]
            end
    end
    val
  end

  def value=(new_value)
    conf_file_modified = document_with_value(new_value)
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
    File.new(file_path, 'w') if @conf_file.nil? && !File.exist?(file_path)
    @conf_file ||= Hocon::Parser::ConfigDocumentFactory.parse_file(file_path)
  end

  def write_conf(conf)
    File.open(file_path, 'w+') do |fh|
      config_string = conf.render
      fh.puts(config_string)
    end
  end

  def conf_object
    File.new(file_path, 'w') if @conf_file.nil? && !File.exist?(file_path)
    Hocon::ConfigFactory.parse_file(file_path).resolve
  end

  def remove_value(value_to_remove)
    if resource[:type] == 'array_element'
      new_value_tmp = Array(value).dup
      Array(value_to_remove).each do |v|
        new_value_tmp.delete(v)
      end
      new_value = Hocon::ConfigValueFactory.from_any_ref(new_value_tmp, nil)
      conf_file.set_config_value(setting, new_value)
    else
      conf_file.remove_value(setting)
    end
  end

  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
  def document_with_value(value_to_set)
    if resource[:type] == 'array_element'
      tmp_val = Array(value).dup
      Array(value_to_set).each do |v|
        tmp_val << v unless tmp_val.include?(v)
      end

      new_value = Hocon::ConfigValueFactory.from_any_ref(tmp_val, nil)
    elsif resource[:type] == 'array' || (value_to_set.is_a?(String) && resource[:type] != 'text') || (value_to_set.is_a?(Array) && value_to_set.size > 1)
      new_value = Hocon::ConfigValueFactory.from_any_ref(value_to_set, nil)
    elsif resource[:type] == 'text'
      new_value = value_to_set[0]
    else
      new_value = Hocon::ConfigValueFactory.from_any_ref(value_to_set[0], nil)
    end

    if resource[:type] == 'text'
      conf_file.set_value(setting, new_value)
    else
      conf_file.set_config_value(setting, new_value)
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
end
# rubocop:enable Metrics/BlockLength
