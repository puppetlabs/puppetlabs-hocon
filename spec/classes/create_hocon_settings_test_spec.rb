require 'spec_helper'
# end-to-end test of the create_hocon_settings function
describe 'create_hocon_settings_test' do
  it { should have_hocon_setting_resource_count(4) }
  it { should contain_hocon_setting('/tmp/foo.conf section1.setting1').with(
      :ensure  => 'present',
      :setting => 'section1.setting1',
      :value   => 'val1',
      :path    => '/tmp/foo.conf'
  )}
  it { should contain_hocon_setting('/tmp/foo.conf section2.setting2').with(
      :ensure  => 'present',
      :setting => 'section2.setting2',
      :value   => 'val2',
      :path    => '/tmp/foo.conf'
  )}
  it { should contain_hocon_setting('/tmp/foo.conf foo.bar.baz').with(
      :ensure  => 'present',
      :setting => 'foo.bar.baz',
      :value   => 'val3',
      :path    => '/tmp/foo.conf'
  )}
end
