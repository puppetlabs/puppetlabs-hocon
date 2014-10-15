conf_setting { 'sample setting':
  ensure  => present,
  path    => '/tmp/foo.conf',
  setting => 'foo.foosetting',
  value   => 'FOO!',
}

conf_setting { 'sample setting2':
  ensure            => present,
  path              => '/tmp/foo.conf',
  setting           => 'bar.barsetting',
  value             => 'BAR!',
  require           => Conf_setting['sample setting'],
}

conf_setting { 'sample setting3':
  ensure  => absent,
  path    => '/tmp/foo.conf',
  section => 'bar',
  setting => 'bar.bazsetting',
  require => Conf_setting['sample setting2'],
}
