require 'puppet'
require 'pp'

require 'net/smtp'
require 'time'

Puppet::Reports.register_report(:tagmail) do

  @tagmail_conf = {}

  desc "This report sends specific log messages to specific email addresses
    based on the tags in the log messages.
    See the [documentation on tags](http://docs.puppetlabs.com/puppet/latest/reference/lang_tags.html) for more information.
    To use this report, you must create a `tagmail.conf` file in your Puppet confdir.
    This is a simple file that maps tags to email addresses, as well as defines some Tagmail configration options.
    Any log messages in the report that match the specified
    tags will be sent to the specified email addresses.
    Lines in the '[tagmap]' section of the `tagmail.conf` file consist of a comma-separated list
    of tags, a colon, and a comma-separated list of email addresses.
    Tags can be !negated with a leading exclamation mark, which will
    subtract any messages with that tag from the set of events handled
    by that line.
    Puppet's log levels (`debug`, `info`, `notice`, `warning`, `err`,
    `alert`, `emerg`, `crit`, and `verbose`) can also be used as tags,
    and there is an `all` tag that will always match all log messages.
    An example `tagmail.conf`:
        [transport]
        sendmail = /usr/sbin/sendmail
        reportfrom = Puppet Master Server
        [tagmap]
        all: me@domain.com
        webserver, !mailserver: httpadmins@domain.com
    This will send all messages to `me@domain.com`, and all messages from
    webservers that are not also from mailservers to `httpadmins@domain.com`.
    If you are using anti-spam controls such as grey-listing on your mail
    server, you should whitelist the sending email address (controlled by
    `reportfrom` configuration option) to ensure your email is not discarded as spam.
    "

  # Find all matching messages.
  def match(taglists)
    matching_logs = []
    taglists.each do |emails, pos, neg|
      # First find all of the messages matched by our positive tags
      messages = nil
      if pos.include?("all")
        messages = self.logs
      else
        # Find all of the messages that are tagged with any of our
        # tags.
        messages = self.logs.find_all do |log|
          pos.detect { |tag| log.tagged?(tag) }
        end
      end

      # Now go through and remove any messages that match our negative tags
      messages = messages.reject do |log|
        true if neg.detect do |tag| log.tagged?(tag) end
      end

      if messages.empty?
        Puppet.info "No messages to report to #{emails.join(",")}"
        next
      else
        matching_logs << [emails, messages.collect { |m| m.to_report }.join("\n")]
      end
    end

    matching_logs
  end

 # Load the config file
  def parse(input)
    taglists = []
    config_hash = {}
    file_hash = {}

    input = input.split("\n")
    section = ''
    input.each do |value|
      if value =~ /^\[.*\]/
        section = value.gsub('[','').gsub(']','')
        file_hash[section.to_sym] = []
      elsif value.strip.length > 0
        if value =~ /^\s*#/
          # do nothing as this is a comment
        elsif section and not section == ''
          file_hash[section.to_sym] << value
        else
          raise Puppet::Error, "Malformed tagmail.conf file"
        end
      end
    end

    if file_hash[:transport]
      file_hash[:transport].each do |value|
        array = value.split('=')
        array.collect do |value|
          value.strip!
        end
        config_hash[array[0].to_sym] = array[1]
      end
    end

    if file_hash[:tagmap]
      tagmap = file_hash[:tagmap].join("\n")
      taglists = parse_tagmap(tagmap)
    end

    config_hash = load_defaults(config_hash)
    self.class.instance_variable_set(:@tagmail_conf, config_hash)
    taglists
  end

  def load_defaults(config_hash)
    if config_hash[:smtpserver]
      if not config_hash[:smtpport] or config_hash[:smtpport] == ''
        config_hash[:smtpport] = '25'
      end

      if not config_hash[:smtphelo] or config_hash[:smtphelo] == ''
        config_hash[:smtphelo] = 'puppet.local'
      end
    end

    if not config_hash[:sendmail] or config_hash[:sendmail] == ''
        config_hash[:sendmail] = '/usr/sbin/sendmail'
      end

    if not config_hash[:reportfrom] or config_hash[:reportfrom] == ''
      config_hash[:reportfrom] = 'Puppet Agent'
    end

    config_hash
  end

  # Load the config file
  def parse_tagmap(text)
    taglists = []
    text.split("\n").each do |line|
      taglist = emails = nil
      case line.chomp
      when /^\s*#/; next
      when /^\s*$/; next
      when /^\s*(.+)\s*:\s*(.+)\s*$/
        taglist = $1
        emails = $2.sub(/#.*$/,'')
      else
        raise ArgumentError, "Invalid tagmail config file"
      end

      pos = []
      neg = []
      taglist.sub(/\s+$/,'').split(/\s*,\s*/).each do |tag|
        unless tag =~ /^!?(?:(::)?[-\w\.]+)*$/
          raise ArgumentError, "Invalid tag #{tag.inspect}"
        end
        case tag
        when /^\w+/; pos << tag
        when /^!\w+/; neg << tag.sub("!", '')
        else
          raise Puppet::Error, "Invalid tag '#{tag}'"
        end
      end

      # Now split the emails
      emails = emails.sub(/\s+$/,'').split(/\s*,\s*/)
      taglists << [emails, pos, neg]
    end
    taglists
  end

  # Process the report.  This just calls the other associated messages.
  def process(tagmail_conf_file = "#{Puppet[:confdir]}/tagmail.conf")
    unless Puppet::FileSystem.exist?(tagmail_conf_file)
      Puppet.notice "Cannot send tagmail report; no tagmap file #{tagmail_conf_file}"
      return
    end

    metrics = raw_summary || {} rescue {}
    metrics['resources'] = metrics['resources'] || {} rescue {}
    metrics['events'] = metrics['events'] || {} rescue {}

    if metrics['resources']['out_of_sync'] == 0 && metrics['resources']['changed'] == 0 && metrics['events']['audit'] == nil
      Puppet.notice "Not sending tagmail report; no changes"
      return
    end

    taglists = parse(File.read(tagmail_conf_file))

    # Now find any appropriately tagged messages.
    reports = match(taglists)

    send(reports) unless reports.empty?
  end

  # Send the email reports.
  def send(reports)
    tagmail_conf = self.class.instance_variable_get(:@tagmail_conf)
    # Run the notification process in a new non-blocking thread

    # Starting a new thread has been commented out as it causes conflict with IO.popen, where the thread just dies
    # after the first run.
    #Thread.new {
      if tagmail_conf[:smtpserver] and tagmail_conf[:smtpserver] != "none"
        begin
          Net::SMTP.start(tagmail_conf[:smtpserver], tagmail_conf[:smtpport], tagmail_conf[:smtphelo]) do |smtp|
            reports.each do |emails, messages|
              smtp.open_message_stream(tagmail_conf[:reportfrom], *emails) do |p|
                p.puts "From: #{tagmail_conf[:reportfrom]}"
                p.puts "Subject: Puppet Report for #{self.host}"
                p.puts "To: " + emails.join(", ")
                p.puts "Date: #{Time.now.rfc2822}"
                p.puts
                p.puts messages
              end
            end
          end
        rescue => detail
          message = "Could not send report emails through smtp: #{detail}"
          Puppet.log_exception(detail, message)
          raise Puppet::Error, message, detail.backtrace
        end
      else
        begin
          reports.each do |emails, messages|
            # We need to open a separate process for every set of email addresses
            IO.popen(tagmail_conf[:sendmail] + " " + emails.join(" "), "w") do |p|
              p.puts "From: #{tagmail_conf[:reportfrom]}"
              p.puts "Subject: Puppet Report for #{self.host}"
              p.puts "To: " + emails.join(", ")
              p.puts
              p.puts messages
            end
          end
        rescue => detail
          message = "Could not send report emails via sendmail: #{detail}"
          Puppet.log_exception(detail, message)
          raise Puppet::Error, message, detail.backtrace
        end
      end
    #}
  end
end