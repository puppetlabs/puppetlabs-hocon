require 'spec_helper_acceptance'

tmpdir = default.tmpdir('tmp')

describe 'conf_setting resource' do
  after :all do
    shell("rm #{tmpdir}/*.conf", :acceptable_exit_codes => [0,1,2])
  end

  shared_examples 'has_content' do |path,pp,content|
    before :all do
      shell("rm #{path}", :acceptable_exit_codes => [0,1,2])
    end
    after :all do
      shell("cat #{path}", :acceptable_exit_codes => [0,1,2])
      shell("rm #{path}", :acceptable_exit_codes => [0,1,2])
    end

    it 'applies the manifest twice' do
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file(path) do
      it { should be_file }
      #XXX Solaris 10 doesn't support multi-line grep
      it("should contain #{content}", :unless => fact('osfamily') == 'Solaris') {
        should contain(content)
      }
    end
  end

  shared_examples 'has_error' do |path,pp,error|
    before :all do
      shell("rm #{path}", :acceptable_exit_codes => [0,1,2])
    end
    after :all do
      shell("cat #{path}", :acceptable_exit_codes => [0,1,2])
      shell("rm #{path}", :acceptable_exit_codes => [0,1,2])
    end

    it 'applies the manifest and gets a failure message' do
      expect(apply_manifest(pp, :expect_failures => true).stderr).to match(error)
    end

    describe file(path) do
      it { should_not be_file }
    end
  end

  describe 'ensure parameter' do
    context '=> present for top-level and nested' do
      pp = <<-EOS
      conf_setting { 'ensure => present for section':
        ensure  => present,
        path    => "#{tmpdir}/conf_setting.conf",
        setting => 'one.two',
        value   => 'three',
      }
      conf_setting { 'ensure => present for top level':
        ensure  => present,
        path    => "#{tmpdir}/conf_setting.conf",
        setting => 'four',
        value   => 'five',
      }
      EOS

      it 'applies the manifest twice' do
        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes => true)
      end

      describe file("#{tmpdir}/conf_setting.conf") do
        it { should be_file }
        #XXX Solaris 10 doesn't support multi-line grep
        it("should contain one {\n    two=three\n}\nfour=five", :unless => fact('osfamily') == 'Solaris') {
          should contain("one {\n    two=three\n}\nfour=five")
        }
      end
    end

    context '=> absent for key/value' do
      before :all do
        if fact('osfamily') == 'Darwin'
          shell("echo \"one {\n    two=three\n}\nfour=five\" > #{tmpdir}/conf_setting.conf")
        else
          shell("echo -e \"one {\n    two=three\n}\nfour=five\" > #{tmpdir}/conf_setting.conf")
        end
      end

      pp = <<-EOS
      conf_setting { 'ensure => absent for key/value':
        ensure  => absent,
        path    => "#{tmpdir}/conf_setting.conf",
        setting => 'one.two',
        value   => 'three',
      }
      EOS

      it 'applies the manifest twice' do
        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes  => true)
      end

      describe file("#{tmpdir}/conf_setting.conf") do
        it { should be_file }
        it { should contain('four=five') }
        it { should_not contain("two=three") }
      end
    end

    context '=> absent for top-level settings' do
      before :all do
        if fact('osfamily') == 'Darwin'
          shell("echo \"one {\n    two=three\n}\nfour=five\" > #{tmpdir}/conf_setting.conf")
        else
          shell("echo -e \"one {\n    two=three\n}\nfour=five\" > #{tmpdir}/conf_setting.conf")
        end
      end
      after :all do
        shell("cat #{tmpdir}/conf_setting.conf", :acceptable_exit_codes => [0,1,2])
        shell("rm #{tmpdir}/conf_setting.conf", :acceptable_exit_codes => [0,1,2])
      end

      pp = <<-EOS
      conf_setting { 'ensure => absent for top-level':
        ensure  => absent,
        path    => "#{tmpdir}/conf_setting.conf",
        setting => 'four',
        value   => 'five',
      }
      EOS

      it 'applies the manifest twice' do
        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes  => true)
      end

      describe file("#{tmpdir}/conf_setting.conf") do
        it { should be_file }
        it { should_not contain('four=five') }
        it { should contain("one {\n    two=three\n}") }
      end
    end
  end

  describe 'section, setting, value parameters' do
    {
      "setting => 'test.foo', value => 'bar',"   => "test {\n    foo = bar\n}",
      "setting => 'more.baz', value => 'quux',"  => "more {\n    baz = quux\n}",
      "setting => 'top', value => 'level',"      => "top=level",
    }.each do |parameter_list, content|
      context parameter_list do
        pp = <<-EOS
        conf_setting { "#{parameter_list}":
          ensure  => present,
          path    => "#{tmpdir}/conf_setting.conf",
          #{parameter_list}
        }
        EOS

        it_behaves_like 'has_content', "#{tmpdir}/conf_setting.conf", pp, content
      end
    end

    {
      ""                                     => /setting is a required.+value is a required/,
      "setting => 'test.foo',"               => /value is a required/,
      "value   => 'bar',"                    => /setting is a required/,
    }.each do |parameter_list, error|
      context parameter_list, :pending => 'no error checking yet' do
        pp = <<-EOS
        conf_setting { "#{parameter_list}":
          ensure  => present,
          path    => "#{tmpdir}/conf_setting.conf",
          #{parameter_list}
        }
        EOS

        it_behaves_like 'has_error', "#{tmpdir}/conf_setting.conf", pp, error
      end
    end
  end

  describe 'path parameter' do
    [
      "#{tmpdir}/one.conf",
      "#{tmpdir}/two.conf",
      "#{tmpdir}/three.conf",
    ].each do |path|
      context "path => #{path}" do
        pp = <<-EOS
        conf_setting { 'path => #{path}':
          ensure  => present,
          setting => 'one.two',
          value   => 'three',
          path    => '#{path}',
        }
        EOS

        it_behaves_like 'has_content', path, pp, "one {\n    two=three\n}"
      end
    end

    context "path => foo" do
      pp = <<-EOS
        conf_setting { 'path => foo':
          ensure     => present,
          setting    => 'one.two',
          value      => 'three',
          path       => 'foo',
        }
      EOS

      it_behaves_like 'has_error', 'foo', pp, /must be fully qualified/
    end
  end
end
