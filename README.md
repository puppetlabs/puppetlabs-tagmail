tagmail
=======
This report processor sends specific log messages to specific email addresses based on the tags in the log messages.  See the [documentation on tags](http://docs.puppetlabs.com/puppet/latest/reference/lang_tags.html) for more information.  To use this report, you must create a `tagmail.conf` file in the location specified by the `tagmap` setting.  This is a simple file that maps tags to email addresses:  Any log messages in the report that match the specified tags will be sent to the specified email addresses.  Lines in the `tagmail.conf` file consist of a comma-separated list of tags, a colon, and a comma-separated list of email addresses.  Tags can be !negated with a leading exclamation mark, which will subtract any messages with that tag from the set of events handled by that line.

Puppet's log levels (`debug`, `info`, `notice`, `warning`, `err`, `alert`, `emerg`, `crit`, and `verbose`) can also be used as tags, and there is an `all` tag that will always match all log messages.

An example `tagmail.conf`:
```
all: me@domain.com
webserver, !mailserver: httpadmins@domain.com
```

This will send all messages to `me@domain.com`, and all messages from webservers that are not also from mailservers to `httpadmins@domain.com`.

If you are using anti-spam controls such as grey-listing on your mail server, you should whitelist the sending email address (controlled by `reportfrom` configuration option) to ensure your email is not discarded as spam.
