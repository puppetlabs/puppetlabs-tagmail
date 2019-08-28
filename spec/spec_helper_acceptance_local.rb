UNSUPPORTED_PLATFORMS = ['windows', 'Solaris', 'Darwin'].freeze
RSpec.configure do |c|
  c.before :suite do
    run_shell('puppet module install puppetlabs-inifile')
  end
end
