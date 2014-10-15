require 'spec_helper'
require 'puppet'

provider_class = Puppet::Type.type(:conf_setting).provider(:ruby)
describe provider_class do
  include PuppetlabsSpec::Files

  let(:tmpfile) { tmpfilename("conf_setting_test.conf") }
  let(:emptyfile) { tmpfilename("conf_setting_test_empty.conf") }

  let(:common_params) { {
      :title    => 'conf_setting_ensure_present_test',
      :path     => tmpfile,
  } }

  def validate_file(expected_content,tmpfile = tmpfile)
    tmpcontent = File.read(tmpfile)
    File.read(tmpfile).should == expected_content
  end


  before :each do
    File.open(tmpfile, 'w') do |fh|
      fh.write(orig_content)
    end
    File.open(emptyfile, 'w') do |fh|
      fh.write("")
    end
  end

  context "when ensuring that a setting is present" do
    let(:orig_content) {
      <<-EOS
# This is a comment
test_key_1: {
// This is also a comment
  foo: foovalue

  bar: barvalue
  master: true
}

test_key_2: {

  foo: foovalue2
  baz: bazvalue
  url: "http://192.168.1.1:8080"
}

"test_key:3": {
  foo: bar
}
    #another comment
// yet another comment
foo: bar
      EOS
    }

    it "should add a missing setting to the correct map" do
      resource = Puppet::Type::Conf_setting.new(common_params.merge(
          :setting => 'test_key_1.yahoo', :value => 'yippee'))
      provider = described_class.new(resource)
      provider.exists?.should be false
      provider.create
      validate_file(<<-EOS
# This is a comment
"test_key_1" {
    # This is also a comment
    foo=foovalue
    bar=barvalue
    master=true
    yahoo=yippee
}
"test_key_2" {
    foo=foovalue2
    baz=bazvalue
    url="http://192.168.1.1:8080"
}
"test_key:3" {
    foo=bar
}
# another comment
# yet another comment
foo=bar
      EOS
)
    end

    it "should modify an existing setting with a different value" do
      resource = Puppet::Type::Conf_setting.new(common_params.merge(
           :setting => 'test_key_2.baz', :value => 'bazvalue2'))
      provider = described_class.new(resource)
      provider.exists?.should be true
      provider.value=('bazvalue2')
      validate_file(<<-EOS
# This is a comment
"test_key_1" {
    # This is also a comment
    foo=foovalue
    bar=barvalue
    master=true
}
"test_key_2" {
    foo=foovalue2
    baz=bazvalue2
    url="http://192.168.1.1:8080"
}
"test_key:3" {
    foo=bar
}
# another comment
# yet another comment
foo=bar
      EOS
      )
    end

    it "should be able to handle settings with non alphanumbering settings " do
      resource = Puppet::Type::Conf_setting.new(common_params.merge(
           :setting => 'test_key_2.url', :value => 'http://192.168.0.1:8080'))
      provider = described_class.new(resource)
      provider.exists?.should be true
      provider.value.should == 'http://192.168.1.1:8080'
      provider.value=('http://192.168.0.1:8080')

      validate_file(<<-EOS
# This is a comment
"test_key_1" {
    # This is also a comment
    foo=foovalue
    bar=barvalue
    master=true
}
"test_key_2" {
    foo=foovalue2
    baz=bazvalue
    url="http://192.168.0.1:8080"
}
"test_key:3" {
    foo=bar
}
# another comment
# yet another comment
foo=bar
      EOS
      )
    end

    it "should recognize an existing setting with the specified value" do
      resource = Puppet::Type::Conf_setting.new(common_params.merge(
           :setting => 'test_key_2.baz', :value => 'bazvalue'))
      provider = described_class.new(resource)
      provider.exists?.should be true
    end

    it "should add a new map if the path contains a non-existent map" do
      resource = Puppet::Type::Conf_setting.new(common_params.merge(
          :setting => 'test_key_4.huzzah', :value => 'shazaam'))
      provider = described_class.new(resource)
      provider.exists?.should be false
      provider.create
      validate_file(<<-EOS
# This is a comment
"test_key_1" {
    # This is also a comment
    foo=foovalue
    bar=barvalue
    master=true
}
"test_key_2" {
    foo=foovalue2
    baz=bazvalue
    url="http://192.168.1.1:8080"
}
"test_key:3" {
    foo=bar
}
# another comment
# yet another comment
foo=bar
"test_key_4" {
    huzzah=shazaam
}
      EOS
      )
    end

    it "should add a new map if no maps exists" do
      resource = Puppet::Type::Conf_setting.new(common_params.merge(
          :setting => 'test_key_1.setting1', :value => 'hellowworld', :path => emptyfile))
      provider = described_class.new(resource)
      provider.exists?.should be false
      provider.create
      validate_file(
"\"test_key_1\" {
    setting1=hellowworld
}
", emptyfile)
    end

    it "should be able to handle variables of any type" do
      resource = Puppet::Type::Conf_setting.new(common_params.merge(
          :setting => 'test_key_1.master', :value => true))
      provider = described_class.new(resource)
      provider.exists?.should be true
      provider.value.should eql(true)
    end

  end

  context "when dealing with settings in the top level" do
    let(:orig_content) {
      <<-EOS
# This is a comment
foo=blah
"test_key_1" {
    # yet another comment
    foo="http://192.168.1.1:8080"
}
      EOS
    }


    it "should add a missing setting if it doesn't exist" do
      resource = Puppet::Type::Conf_setting.new(common_params.merge(
          :setting => 'bar', :value => 'yippee'))
      provider = described_class.new(resource)
      provider.exists?.should be false
      provider.create
      validate_file(<<-EOS
# This is a comment
foo=blah
"test_key_1" {
    # yet another comment
    foo="http://192.168.1.1:8080"
}
bar=yippee
      EOS
      )
    end

    # TODO: Investigate removal of comment
    it "should modify an existing setting with a different value" do
      resource = Puppet::Type::Conf_setting.new(common_params.merge(
           :setting => 'foo', :value => 'yippee'))
      provider = described_class.new(resource)
      provider.exists?.should be true
      provider.value.should == 'blah'
      provider.value=('yippee')
      validate_file(<<-EOS
foo=yippee
"test_key_1" {
    # yet another comment
    foo="http://192.168.1.1:8080"
}
      EOS
      )
    end

    it "should recognize an existing setting with the specified value" do
      resource = Puppet::Type::Conf_setting.new(common_params.merge(
           :setting => 'foo', :value => 'blah'))
      provider = described_class.new(resource)
      provider.exists?.should be true
    end
  end

   context "when the first line of the file is a section" do
    let(:orig_content) {
      <<-EOS
"test_key_2" {
    foo="http://192.168.1.1:8080"
}
      EOS
    }

    it "should be able to add a setting to the top-level map" do
      resource = Puppet::Type::Conf_setting.new(common_params.merge(
           :setting => 'foo', :value => 'yippee'))
      provider = described_class.new(resource)
      provider.exists?.should be false
      provider.create
      validate_file(<<-EOS
"test_key_2" {
    foo="http://192.168.1.1:8080"
}
foo=yippee
      EOS
      )
    end
  end

  context "when ensuring that a setting is absent" do
    let(:orig_content) {
      <<-EOS
"test_key_1" {
    # This is also a comment
    foo=foovalue
    bar=barvalue
    master=true
}
"test_key_2" {
    foo=foovalue2
    baz=bazvalue
    url="http://192.168.1.1:8080"
}
"test_key_3" {
    subby=bar
}
EOS
    }

    it "should remove a setting that exists" do
      resource = Puppet::Type::Conf_setting.new(common_params.merge(
      :setting => 'test_key_1.foo', :ensure => 'absent'))
      provider = described_class.new(resource)
      provider.exists?.should be true
      provider.destroy
      validate_file(<<-EOS
"test_key_1" {
    bar=barvalue
    master=true
}
"test_key_2" {
    foo=foovalue2
    baz=bazvalue
    url="http://192.168.1.1:8080"
}
"test_key_3" {
    subby=bar
}
      EOS
    )
    end

    it "should do nothing for a setting that does not exist" do
      resource = Puppet::Type::Conf_setting.new(common_params.merge(
                                                   :setting => 'test_key_3.foo', :ensure => 'absent'))
      provider = described_class.new(resource)
      provider.exists?.should be false
      provider.destroy
      validate_file(<<-EOS
"test_key_1" {
    # This is also a comment
    foo=foovalue
    bar=barvalue
    master=true
}
"test_key_2" {
    foo=foovalue2
    baz=bazvalue
    url="http://192.168.1.1:8080"
}
"test_key_3" {
    subby=bar
}
      EOS
      )
    end
  end
end
