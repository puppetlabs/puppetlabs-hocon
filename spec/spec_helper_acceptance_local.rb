# frozen_string_literal: true

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation

  c.before :suite do
    include PuppetLitmus
    extend PuppetLitmus

    pp = <<-MANIFEST
    package { 'hocon':
      ensure   => 'latest',
      provider => 'puppet_gem',
    }
    file { '#{os_tmpdir}':
      ensure  => directory,
      force   => true,
      purge   => true,
      recurse => true,
    }
    file { '#{os_tmpdir}/file':
      content => "file exists\n",
      force   => true,
    }
    MANIFEST

    apply_manifest(pp)
  end
end

def os_tmpdir
  case os[:family]
  when 'windows'
    'c:/hocon_test'
  else
    '/tmp/hocon_test'
  end
end
