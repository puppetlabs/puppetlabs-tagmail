# tagmail

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
4. [Limitations - OS compatibility, etc.](#limitations)

## Overview

This is a plug-in replacement of the existing built-in tagmail report processor. Tagmail is a very often used feature in Puppet. It is used to send email notifications based on tags associated to resources or classes. The tagmail feature is broken in the JVM based PE 3.4 and is scheduled to be completely removed in PE 4.0. This is a module that provides an alternative and replaces the same functionality as available in tagmail prior to PE 3.4.

## Module Description

This module is a [report processor](https://docs.puppetlabs.com/guides/reporting.html) plugin to generate a tagmail report. The tagmail report sends specific log messages via email based on the tags that are present in each log message. Tags allow users to set context for resources; for example, one can tag all resources that belong to a particular operating system, location, or any other characteristic. See the [documentation on tags](http://docs.puppetlabs.com/puppet/latest/reference/lang_tags.html) for more information. Tags can also be specified in the `puppet.conf` configuration file to tell the agents to apply only configurations tagged with the specified tags.
The tagmail report uses the same tags to generate email reports. The tags assigned to the resources are added to the log results, and then Puppet generates email based on matching particular tags with particular email addresses. This matching is configured in a configuration file called `tagmail.conf`. By default, the tagmail.conf file is located in the $confdir directory. This is controlled by the tagmap configuration option in the puppet.conf file:

```
[master]
tagmap = $confdir/tagmail.conf
```

To use this report, you must create a `tagmail.conf` file in the location specified by the `tagmap` setting. The value of the tagmap setting can be looked up using `puppet master --configprint tagmap` on the puppet master.  The `tagmail.conf` is a simple file that maps tags to email addresses:  Any log messages in the report that match the specified tags will be sent to the specified email addresses.  Lines in the `tagmail.conf` file consist of a comma-separated list of tags, a colon, and a comma-separated list of email addresses. Tags can be !negated with a leading exclamation mark, which will subtract any messages with that tag from the set of events handled by that line.

Puppet's log levels (`debug`, `info`, `notice`, `warning`, `err`, `alert`, `emerg`, `crit`, and `verbose`) can also be used as tags, and there is an `all` tag that will always match all log messages.

An example `tagmail.conf`:
```
all: me@domain.com
webserver, !mailserver: httpadmins@domain.com
```

This will send all messages to `me@domain.com`, and all messages from webservers that are not also from mailservers to `httpadmins@domain.com`.

If you are using anti-spam controls such as grey-listing on your mail server, you should whitelist the sending email address (controlled by `reportfrom` configuration option) to ensure your email is not discarded as spam.
The tagmail.conf file contains a list of tags and email addresses separated by colons. Multiple tags and email addresses can be specified by separating them with commas.

## Reference

This module has been built in direct response to the ticket below:

https://tickets.puppetlabs.com/browse/SERVER-62

## Limitations

This module should be used only for PE >3.4 or Puppet 3.7 onwards and only if using the JVM on the puppet master. For older versions of Puppet or if using the legacy puppet master on Apache/Rack/Passenger, then the tagmail feature built into the core of Puppet should be used.



