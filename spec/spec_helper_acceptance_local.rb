require 'singleton'

class LitmusHelper
  include Singleton
  include PuppetLitmus
end

UNSUPPORTED_PLATFORMS = ['windows', 'Solaris', 'Darwin'].freeze
RSpec.configure do |c|
  c.before :suite do
    LitmusHelper.instance.run_shell('puppet module install puppetlabs-inifile')
  end
end
