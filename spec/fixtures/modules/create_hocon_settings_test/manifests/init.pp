# simple test class
class create_hocon_settings_test {
  $settings = {
    section1 => {
      setting1 => val1
    },
    section2 => {
      setting2 => val2,
      setting3 => {
        ensure => absent
      }
    },
    'foo.bar' => {
      baz => val3
    }
  }
  $defaults = {
    path => '/tmp/foo.conf'
  }
  create_hocon_settings($settings,$defaults)
}
