require 'spec_helper_acceptance'

describe 'tagmail tests', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do

  before(:all) do
    pp = <<-EOS
      ini_setting { "tagmailconf1":
        ensure  => present,
        path    => "${::settings::confdir}/puppet.conf",
        section => 'master',
        setting => 'tagmap',
        value   => '$confdir/tagmail.conf',
      }

      ini_setting { "tagmailconf2":
        ensure  => present,
        path    => "${::settings::confdir}/puppet.conf",
        section => 'master',
        setting => 'reports',
        value   => 'puppetdb,console,tagmail',
      }

      ini_setting { "tagmailconf3":
        ensure  => present,
        path    => "${::settings::confdir}/puppet.conf",
        section => 'user',
        setting => 'reports',
        value   => 'tagmail',
      }

      file {"${::settings::confdir}/tagmail.conf":
        ensure => present,
        content => 'all: foo@localhost,bar@localhost\ntag1: baz@localhost\ntag2, !tag3: qux@localhost\ntag3: fred@localhost',
      }

      user {'foo':
        ensure => present,
      }

      user {'bar':
        ensure => present,
      }

      user {'baz':
        ensure => present,
      }

      user {'qux':
        ensure => present,
      }

      user {'fred':
        ensure => present,
      }
      EOS

    apply_manifest(pp, :catch_failures => true)

    pp_sendmail = <<-EOS
        if $::operatingsystem == 'Debian' {
          package { "sendmail-bin" :
            ensure => installed,
            before => Package['sendmail'],
          }
        }

        if $::osfamily == 'Redhat' {
          service {'postfix':
            ensure => stopped,
            before => Service['sendmail'],
          }

          package { "sendmail-cf" :
            ensure => installed,
            require => Package['sendmail'],
          }

          exec {"sed -i 's/Addr=127\.0\.0\.1, //g' /etc/mail/sendmail.mc ; /usr/bin/m4 /etc/mail/sendmail.mc > /etc/mail/sendmail.cf":
            notify => Service['sendmail'],
            require => Package['sendmail-cf'],
            path => '/bin',
          }
        }

        package { "sendmail" :
          ensure => installed,
        }

        service {'sendmail':
          ensure => running,
          require => Package['sendmail'],
        }
        
      EOS

    apply_manifest(pp_sendmail, :catch_failures => true)
  end

  describe 'tagmail' do
    context 'group all tests' do
      it 'applies' do
        pp = <<-EOS
          notify {'This is a test that should be present for all':
            tag => ['undefinedtag'],
          }
        EOS

        apply_manifest(pp, :catch_failures => true)
      end

      it 'should contain the text' do
         shell('sleep 10; cat /var/spool/mail/foo || true 2>&1') do |r|
           expect(r.stdout).to match(/This is a test that should be present for all/)
         end
      end
      it 'should contain the text' do
         shell('cat /var/spool/mail/bar || true 2>&1') do |r|
           expect(r.stdout).to match(/This is a test that should be present for all/)
         end
      end
      it 'should not contain the text' do
         shell('cat /var/spool/mail/baz || true 2>&1') do |r|
           expect(r.stdout).to_not match(/This is a test that should be present for all/)
         end
      end
      it 'should not contain the text' do
         shell('cat /var/spool/mail/qux || true 2>&1') do |r|
           expect(r.stdout).to_not match(/This is a test that should be present for all/)
         end
      end
      it 'should not contain the text' do
         shell('cat /var/spool/mail/fred || true 2>&1') do |r|
           expect(r.stdout).to_not match(/This is a test that should be present for all/)
         end
      end
    end

    context 'group tag1 tests' do
      it 'applies' do
        pp = <<-EOS
          notify {'This is a test that should be present for tag1':
            tag => ['tag1'],
          }
        EOS

        apply_manifest(pp, :catch_failures => true)
      end

      it 'should contain the text' do
         shell('sleep 5; cat /var/spool/mail/foo || true 2>&1') do |r|
           expect(r.stdout).to match(/This is a test that should be present for tag1/)
         end
      end
      it 'should contain the text' do
         shell('cat /var/spool/mail/bar || true 2>&1') do |r|
           expect(r.stdout).to match(/This is a test that should be present for tag1/)
         end
      end
      it 'should contain the text' do
         shell('cat /var/spool/mail/baz || true 2>&1') do |r|
           expect(r.stdout).to match(/This is a test that should be present for tag1/)
         end
      end
      it 'should not contain the text' do
         shell('cat /var/spool/mail/qux || true 2>&1') do |r|
           expect(r.stdout).to_not match(/This is a test that should be present for tag1/)
         end
      end
      it 'should not contain the text' do
         shell('cat /var/spool/mail/fred || true 2>&1') do |r|
           expect(r.stdout).to_not match(/This is a test that should be present for tag1/)
         end
      end
    end

    context 'group tag2 tests' do
      it 'applies' do
        pp = <<-EOS
          notify {'This is a test that should be present for tag2':
            tag => ['tag2'],
          }
        EOS

        apply_manifest(pp, :catch_failures => true)
      end

      it 'should contain the text' do
         shell('sleep 5; cat /var/spool/mail/foo || true 2>&1') do |r|
           expect(r.stdout).to match(/This is a test that should be present for tag2/)
         end
      end
      it 'should contain the text' do
         shell('cat /var/spool/mail/bar || true 2>&1') do |r|
           expect(r.stdout).to match(/This is a test that should be present for tag2/)
         end
      end
      it 'should not contain the text' do
         shell('cat /var/spool/mail/baz || true 2>&1') do |r|
           expect(r.stdout).to_not match(/This is a test that should be present for tag2/)
         end
      end
      it 'should contain the text' do
         shell('cat /var/spool/mail/qux || true 2>&1') do |r|
           expect(r.stdout).to match(/This is a test that should be present for tag2/)
         end
      end
      it 'should not contain the text' do
         shell('cat /var/spool/mail/fred || true 2>&1') do |r|
           expect(r.stdout).to_not match(/This is a test that should be present for tag2/)
         end
      end
    end

    context 'group tag3 tests' do
      it 'applies' do
        pp = <<-EOS
          notify {'This is a test that should be present for tag3':
            tag => ['tag3'],
          }
        EOS

        apply_manifest(pp, :catch_failures => true)
      end

      it 'should contain the text' do
         shell('sleep 5; cat /var/spool/mail/foo || true 2>&1') do |r|
           expect(r.stdout).to match(/This is a test that should be present for tag3/)
         end
      end
      it 'should contain the text' do
         shell('cat /var/spool/mail/bar || true 2>&1') do |r|
           expect(r.stdout).to match(/This is a test that should be present for tag3/)
         end
      end
      it 'should not contain the text' do
         shell('cat /var/spool/mail/baz || true 2>&1') do |r|
           expect(r.stdout).to_not match(/This is a test that should be present for tag3/)
         end
      end
      it 'should not contain the text' do
         shell('cat /var/spool/mail/qux || true 2>&1') do |r|
           expect(r.stdout).to_not match(/This is a test that should be present for tag3/)
         end
      end
      it 'should contain the text' do
         shell('cat /var/spool/mail/fred || true 2>&1') do |r|
           expect(r.stdout).to match(/This is a test that should be present for tag3/)
         end
      end
    end

    context 'group tag2 and tag3 tests' do
      it 'applies' do
        pp = <<-EOS
          notify {'This is a test that should be present for tag3':
            tag => ['tag2', 'tag3'],
          }
        EOS

        apply_manifest(pp, :catch_failures => true)
      end

      it 'should contain the text' do
         shell('sleep 5; cat /var/spool/mail/foo || true 2>&1') do |r|
           expect(r.stdout).to match(/This is a test that should be present for tag3/)
         end
      end
      it 'should contain the text' do
         shell('cat /var/spool/mail/bar || true 2>&1') do |r|
           expect(r.stdout).to match(/This is a test that should be present for tag3/)
         end
      end
      it 'should not contain the text' do
         shell('cat /var/spool/mail/baz || true 2>&1') do |r|
           expect(r.stdout).to_not match(/This is a test that should be present for tag3/)
         end
      end
      it 'should not contain the text' do
         shell('cat /var/spool/mail/qux || true 2>&1') do |r|
           expect(r.stdout).to_not match(/This is a test that should be present for tag3/)
         end
      end
      it 'should contain the text' do
         shell('cat /var/spool/mail/fred || true 2>&1') do |r|
           expect(r.stdout).to match(/This is a test that should be present for tag3/)
         end
      end
    end
  end
end
