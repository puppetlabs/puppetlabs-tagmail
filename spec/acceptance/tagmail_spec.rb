require 'spec_helper_acceptance'

unless fact('operatingsystem') == 'Scientific' && fact('operatingsystemmajrelease') == '6'
  describe 'tagmail tests', unless: UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
    before(:all) do
      pp = <<-MANIFEST
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
          content => '[transport]\nreportfrom=MyPuppetAgent\n\n[tagmap]\nall: foo@localhost,bar@localhost\ntag1: baz@localhost\ntag2, !tag3: qux@localhost\ntag3: fred@localhost',
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
        MANIFEST

      apply_manifest(pp, catch_failures: true)

      pp_sendmail = <<-MANIFEST
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

        MANIFEST

      apply_manifest(pp_sendmail, catch_failures: true)
    end

    describe 'tagmail' do
      context 'with group all tests' do
        pp = <<-MANIFEST
            notify {'This is a test that should be present for all':
              tag => ['undefinedtag'],
            }
        MANIFEST
        it 'applies' do
          apply_manifest(pp, catch_failures: true)
        end

        it 'contains the text - foo' do
          shell('sleep 10; cat /var/spool/mail/foo || true 2>&1') do |r|
            expect(r.stdout).to match(%r{This is a test that should be present for all})
          end
        end
        it 'contains the text - bar' do
          shell('cat /var/spool/mail/bar || true 2>&1') do |r|
            expect(r.stdout).to match(%r{This is a test that should be present for all})
          end
        end
        it 'does not contain the text - baz' do
          shell('cat /var/spool/mail/baz || true 2>&1') do |r|
            expect(r.stdout).not_to match(%r{This is a test that should be present for all})
          end
        end
        it 'does not contain the text - qux' do
          shell('cat /var/spool/mail/qux || true 2>&1') do |r|
            expect(r.stdout).not_to match(%r{This is a test that should be present for all})
          end
        end
        it 'does not contain the text - fred' do
          shell('cat /var/spool/mail/fred || true 2>&1') do |r|
            expect(r.stdout).not_to match(%r{This is a test that should be present for all})
          end
        end
      end

      context 'with group tag1 tests' do
        pp = <<-MANIFEST
            notify {'This is a test that should be present for tag1':
              tag => ['tag1'],
            }
        MANIFEST
        it 'applies' do
          apply_manifest(pp, catch_failures: true)
        end

        it 'contains the text - foo' do
          shell('sleep 10; cat /var/spool/mail/foo || true 2>&1') do |r|
            expect(r.stdout).to match(%r{This is a test that should be present for tag1})
          end
        end
        it 'contains the text - bar' do
          shell('cat /var/spool/mail/bar || true 2>&1') do |r|
            expect(r.stdout).to match(%r{This is a test that should be present for tag1})
          end
        end
        it 'contains the text - baz' do
          shell('cat /var/spool/mail/baz || true 2>&1') do |r|
            expect(r.stdout).to match(%r{This is a test that should be present for tag1})
          end
        end
        it 'does not contain the text - quz' do
          shell('cat /var/spool/mail/qux || true 2>&1') do |r|
            expect(r.stdout).not_to match(%r{This is a test that should be present for tag1})
          end
        end
        it 'does not contain the text - fred' do
          shell('cat /var/spool/mail/fred || true 2>&1') do |r|
            expect(r.stdout).not_to match(%r{This is a test that should be present for tag1})
          end
        end
      end

      context 'with group tag2 tests' do
        pp = <<-MANIFEST
            notify {'This is a test that should be present for tag2':
              tag => ['tag2'],
            }
        MANIFEST
        it 'applies' do
          apply_manifest(pp, catch_failures: true)
        end

        it 'contains the text - foo' do
          shell('sleep 10; cat /var/spool/mail/foo || true 2>&1') do |r|
            expect(r.stdout).to match(%r{This is a test that should be present for tag2})
          end
        end
        it 'contains the text - bar' do
          shell('cat /var/spool/mail/bar || true 2>&1') do |r|
            expect(r.stdout).to match(%r{This is a test that should be present for tag2})
          end
        end
        it 'does not contain the text - baz' do
          shell('cat /var/spool/mail/baz || true 2>&1') do |r|
            expect(r.stdout).not_to match(%r{This is a test that should be present for tag2})
          end
        end
        it 'contains the text - quz' do
          shell('cat /var/spool/mail/qux || true 2>&1') do |r|
            expect(r.stdout).to match(%r{This is a test that should be present for tag2})
          end
        end
        it 'does not contain the text - fred' do
          shell('cat /var/spool/mail/fred || true 2>&1') do |r|
            expect(r.stdout).not_to match(%r{This is a test that should be present for tag2})
          end
        end
      end

      context 'with group tag3 tests' do
        pp = <<-MANIFEST
            notify {'This is a test that should be present for tag3':
              tag => ['tag3'],
            }
        MANIFEST
        it 'applies' do
          apply_manifest(pp, catch_failures: true)
        end

        it 'contains the text - foo' do
          shell('sleep 10; cat /var/spool/mail/foo || true 2>&1') do |r|
            expect(r.stdout).to match(%r{This is a test that should be present for tag3})
          end
        end
        it 'contains the text - bar' do
          shell('cat /var/spool/mail/bar || true 2>&1') do |r|
            expect(r.stdout).to match(%r{This is a test that should be present for tag3})
          end
        end
        it 'does not contain the text - baz' do
          shell('cat /var/spool/mail/baz || true 2>&1') do |r|
            expect(r.stdout).not_to match(%r{This is a test that should be present for tag3})
          end
        end
        it 'does not contain the text - quz' do
          shell('cat /var/spool/mail/qux || true 2>&1') do |r|
            expect(r.stdout).not_to match(%r{This is a test that should be present for tag3})
          end
        end
        it 'contains the text - fred' do
          shell('cat /var/spool/mail/fred || true 2>&1') do |r|
            expect(r.stdout).to match(%r{This is a test that should be present for tag3})
          end
        end
      end

      context 'with group tag2 and tag3 tests' do
        pp = <<-MANIFEST
            notify {'This is a test that should be present for tag3':
              tag => ['tag2', 'tag3'],
            }
        MANIFEST
        it 'applies' do
          apply_manifest(pp, catch_failures: true)
        end

        it 'contains the text - foo' do
          shell('sleep 10; cat /var/spool/mail/foo || true 2>&1') do |r|
            expect(r.stdout).to match(%r{This is a test that should be present for tag3})
          end
        end
        it 'contains the text - bar' do
          shell('cat /var/spool/mail/bar || true 2>&1') do |r|
            expect(r.stdout).to match(%r{This is a test that should be present for tag3})
          end
        end
        it 'does not contain the text - baz' do
          shell('cat /var/spool/mail/baz || true 2>&1') do |r|
            expect(r.stdout).not_to match(%r{This is a test that should be present for tag3})
          end
        end
        it 'does not contain the text - quz' do
          shell('cat /var/spool/mail/qux || true 2>&1') do |r|
            expect(r.stdout).not_to match(%r{This is a test that should be present for tag3})
          end
        end
        it 'contains the text - fred' do
          shell('cat /var/spool/mail/fred || true 2>&1') do |r|
            expect(r.stdout).to match(%r{This is a test that should be present for tag3})
          end
        end
      end

      context 'with reportfrom test' do
        pp = <<-MANIFEST
            file {"${::settings::confdir}/tagmail.conf":
              ensure => present,
              content => '[transport]\nreportfrom=MyCoolPuppetAgent\n\n[tagmap]\nall: foo@localhost,bar@localhost\ntag1: baz@localhost\ntag2, !tag3: qux@localhost\ntag3: fred@localhost',
            }

            notify {'This is a test that should be present for all':
              tag => ['undefinedtag'],
              require => File["${::settings::confdir}/tagmail.conf"]
            }
        MANIFEST
        it 'applies' do
          apply_manifest(pp, catch_failures: true)
        end

        it 'contains the reportfrom text - foo' do
          shell('sleep 10; cat /var/spool/mail/foo || true 2>&1') do |r|
            expect(r.stdout).to match(%r{From: MyCoolPuppetAgent})
          end
        end
      end
    end
  end
end
