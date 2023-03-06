# frozen_string_literal: true

require 'puppet'
require 'pp'

require 'net/smtp'
require 'time'
require 'tempfile'

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
        reportfrom = Puppet Server
        [tagmap]
        all: me@domain.com
        webserver, !mailserver: httpadmins@domain.com
    This will send all messages to `me@domain.com`, and all messages from
    webservers that are not also from mailservers to `httpadmins@domain.com`.
    If you are using anti-spam controls such as grey-listing on your mail
    server, you should allowlist the sending email address (controlled by
    `reportfrom` configuration option) to ensure your email is not discarded as spam.
    "

  # Find all matching messages.
  def match(taglists)
    matching_logs = []
    taglists.each do |emails, pos, neg|
      # First find all of the messages matched by our positive tags
      messages = if pos.include?('all')
                   logs
                 else
                   # Find all of the messages that are tagged with any of our
                   # tags.
                   logs.select do |log|
                     pos.find { |tag| log.tagged?(tag) }
                   end
                 end

      # Now go through and remove any messages that match our negative tags
      messages = messages.reject do |log|
        true if neg.find { |tag| log.tagged?(tag) }
      end

      if messages.empty?
        Puppet.info "No messages to report to #{emails.join(',')}"
        next
      else
        matching_logs << [emails, messages.map(&:to_report).join("\n")]
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
      if value.match?(%r{^\[.*\]})
        section = value.delete('[').delete(']')
        file_hash[section.to_sym] = []
      elsif !value.strip.empty?
        if value.match?(%r{^\s*#})
          # do nothing as this is a comment
        elsif section && (section != '')
          file_hash[section.to_sym] << value
        else
          raise Puppet::Error, 'Malformed tagmail.conf file'
        end
      end
    end

    file_hash[:transport]&.each do |value|
      array = value.split('=')
      array.map(&:strip!)
      config_hash[array[0].to_sym] = array[1]
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
      if !(config_hash[:smtpport]) || config_hash[:smtpport] == ''
        config_hash[:smtpport] = '25'
      end

      if !(config_hash[:smtphelo]) || config_hash[:smtphelo] == ''
        config_hash[:smtphelo] = 'puppet.local'
      end

      if !(config_hash[:smtpuser]) || config_hash[:smtpuser] == ''
        config_hash[:smtpuser] = nil
      end

      if !(config_hash[:smtpsecret]) || config_hash[:smtpsecret] == ''
        config_hash[:smtpsecret] = nil
      end

      if !(config_hash[:smtpauthtype]) || config_hash[:smtpauthtype] == ''
        config_hash[:smtpauthtype] = nil
      end

      if !(config_hash[:smtptls]) || config_hash[:smtptls] == ''
        # Match upstream Net::SMTP default for tls
        # https://github.com/ruby/net-smtp/blob/9e44412d0da2dc7697bc45973e9ed12f5b4acfb5/lib/net/smtp.rb#L520
        config_hash[:smtptls] = false
      end

      if !(config_hash[:smtpstarttls]) || config_hash[:smtpstarttls] == ''
        # Match upstream Net::SMTP default for starttls
        # https://github.com/ruby/net-smtp/blob/9e44412d0da2dc7697bc45973e9ed12f5b4acfb5/lib/net/smtp.rb#L520
        config_hash[:smtpstarttls] = :auto
      end

      if !(config_hash[:smtptls_verify]) || config_hash[:smtptls_verify] == ''
        # Match upstream Net::SMTP default for tls_verify
        # https://github.com/ruby/net-smtp/blob/9e44412d0da2dc7697bc45973e9ed12f5b4acfb5/lib/net/smtp.rb#L521
        config_hash[:smtptls_verify] = true
      end

      if !(config_hash[:smtptls_hostname]) || config_hash[:smtptls_hostname] == ''
        # Match upstream Net::SMTP default for tls_hostname
        # https://github.com/ruby/net-smtp/blob/9e44412d0da2dc7697bc45973e9ed12f5b4acfb5/lib/net/smtp.rb#L521
        config_hash[:smtptls_hostname] = true
      end
    end

    if !(config_hash[:sendmail]) || config_hash[:sendmail] == ''
      config_hash[:sendmail] = '/usr/sbin/sendmail'
    end

    if !(config_hash[:reportfrom]) || config_hash[:reportfrom] == ''
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
      when %r{^\s*#} then next
      when %r{^\s*$} then next
      when %r{^\s*(.+)\s*:\s*(.+)\s*$}
        taglist = Regexp.last_match(1)
        emails = Regexp.last_match(2).sub(%r{#.*$}, '')
      else
        raise ArgumentError, 'Invalid tagmail config file'
      end

      pos = []
      neg = []
      taglist.sub(%r{\s+$}, '').split(%r{\s*,\s*}).each do |tag|
        unless tag.match?(%r{^!?(?:(::)?[-\w\.]+)*$})
          raise ArgumentError, "Invalid tag #{tag.inspect}"
        end
        case tag
        when %r{^\w+} then pos << tag
        when %r{^!\w+} then neg << tag.sub('!', '')
        else
          raise Puppet::Error, "Invalid tag '#{tag}'"
        end
      end

      # Now split the emails
      emails = emails.sub(%r{\s+$}, '').split(%r{\s*,\s*})
      taglists << [emails, pos, neg]
    end
    taglists
  end

  # Process the report.  This just calls the other associated messages.
  def process(tagmail_conf_file = (Puppet[:confdir] + '/tagmail.conf'))
    unless Puppet::FileSystem.exist?(tagmail_conf_file)
      Puppet.notice "Cannot send tagmail report; no tagmap file #{tagmail_conf_file}"
      return
    end

    metrics = begin
                raw_summary || {}
              rescue StandardError
                {}
              end
    metrics['resources'] = begin
                             metrics['resources'] || {}
                           rescue StandardError
                             {}
                           end
    metrics['events'] = begin
                          metrics['events'] || {}
                        rescue StandardError
                          {}
                        end

    # Check for 'err' level logs, which indicates failed catalog
    logs_err = logs.index { |x| x.level.to_s == 'err' }

    # Altering to "(metrics['resources']['out_of_sync'] ).zero?" from "metrics['resources']['out_of_sync'] == 0" as causes tests to fail due to 'nil:NilClass' errors.
    if logs_err.nil? && metrics['resources']['out_of_sync'] == 0 && metrics['resources']['changed'] == 0 && metrics['events']['audit'].nil?

      Puppet.notice 'Not sending tagmail report; no changes'
      return
    end

    taglists = parse(File.read(tagmail_conf_file))

    # Now find any appropriately tagged messages.
    reports = match(taglists)
    reports.reject! { |item| item =~ %r{Applied\ catalog\ in\ .*\ seconds} }
    send(reports) unless reports.empty?
  end

  # Send the email reports.
  def send(reports)
    tagmail_conf = self.class.instance_variable_get(:@tagmail_conf)
    # Run the notification process in a new non-blocking thread

    # Starting a new thread has been commented out as it causes conflict with IO.popen, where the thread just dies
    # after the first run.
    # Thread.new {
    if tagmail_conf[:smtpserver] && tagmail_conf[:smtpserver] != 'none'
      begin
        Net::SMTP.start(tagmail_conf[:smtpserver],
                        tagmail_conf[:smtpport],
                        helo: tagmail_conf[:smtphelo],
                        user: tagmail_conf[:smtpuser],
                        secret: tagmail_conf[:smtpsecret],
                        authtype: tagmail_conf[:smtpauthtype],
                        tls: tagmail_conf[:smtptls],
                        starttls: tagmail_conf[:smtpstarttls],
                        tls_verify: tagmail_conf[:smtptls_verify],
                        tls_hostname: tagmail_conf[:smtptls_hostname],
                       ) do |smtp|
          reports.each do |emails, messages|
            smtp.open_message_stream(tagmail_conf[:reportfrom], *emails) do |p|
              p.puts "From: #{tagmail_conf[:reportfrom]}"
              p.puts "Subject: Puppet Report for #{host}"
              p.puts 'To: ' + emails.join(', ')
              p.puts "Date: #{Time.now.rfc2822}"
              p.puts
              p.puts messages
            end
          end
        end
      rescue StandardError => detail
        message = "Could not send report emails through smtp: #{detail}"
        Puppet.log_exception(detail, message)
        raise Puppet::Error, message, detail.backtrace
      end
    else
      begin
        reports.each do |emails, messages|
          email = Tempfile.new('tagmail')
          begin
            email.write("From: #{tagmail_conf[:reportfrom]}\n")
            email.write("Subject: Puppet Report for #{host}\n")
            email.write("To: #{emails.join(', ')}\n\n")
            email.write(messages)
            email.rewind
            Puppet::Util::Execution.execute("#{tagmail_conf[:sendmail]} #{emails.join(' ')} < #{email.path}")
          ensure
            email.close
            email.unlink
          end
        end
      rescue StandardError => detail
        message = "Could not send report emails via sendmail: #{detail}"
        Puppet.log_exception(detail, message)
        raise Puppet::Error, message, detail.backtrace
      end
    end
    # }
  end
end
