# tagmail

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Installation and Usage](#installation-and-usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)

## Overview

This is a plug-in replacement of the existing built-in tagmail report processor. Tagmail is a very often used feature in Puppet. It is used to send email notifications based on tags associated to resources or classes. The tagmail feature is broken in the JVM based PE 3.4 and is scheduled to be completely removed in PE 4.0. This is a module that provides an alternative and replaces the same functionality as available in tagmail prior to PE 3.4.

## Module Description

This module is a [report processor](https://docs.puppetlabs.com/guides/reporting.html) plugin to generate a tagmail report. The tagmail report sends specific log messages via email based on the tags that are present in each log message. Tags allow users to set context for resources; for example, one can tag all resources that belong to a particular operating system, location, or any other characteristic. See the [documentation on tags](http://docs.puppetlabs.com/puppet/latest/reference/lang_tags.html) for more information. Tags can also be specified in the `puppet.conf` configuration file to tell the agents to apply only configurations tagged with the specified tags.
The tagmail report uses the same tags to generate email reports. The tags assigned to the resources are added to the log results, and then Puppet generates email based on matching particular tags with particular email addresses. This matching is configured in a configuration file called `tagmail.conf`. By default, the tagmail.conf file is located in the $confdir directory. This is controlled by the tagmap configuration option in the puppet.conf file. Also ensure that `tagmail` is set as one of the (comma separated) values for the `reports` configuration as shown below:

```
[master]
tagmap = $confdir/tagmail.conf
reports = puppetdb,console,tagmail
```

On the agent ensure pluginsync is enabled. It is enabled by default.

```
[agent]
report = true
pluginsync = true
```

## Installation and Usage

To use this report, you must create a `tagmail.conf` file on the puppet master in the location specified by the `tagmap` setting. The value of the tagmap setting can be looked up using `puppet master --configprint tagmap` on the puppet master.  The `tagmail.conf` is a simple file that maps tags to email addresses:  Any log messages in the report that match the specified tags will be sent to the specified email addresses.  Lines in the `tagmail.conf` file consist of a comma-separated list of tags, a colon, and a comma-separated list of email addresses. Tags can be !negated with a leading exclamation mark, which will subtract any messages with that tag from the set of events handled by that line.

Puppet's log levels (`debug`, `info`, `notice`, `warning`, `err`, `alert`, `emerg`, `crit`, and `verbose`) can also be used as tags, and there is an `all` tag that will always match all log messages.

An example `tagmail.conf`:
```
all: me@domain.com
webserver, !mailserver: httpadmins@domain.com
```

This will send all messages to `me@domain.com`, and all messages from webservers that are not also from mailservers to `httpadmins@domain.com`.

If you are using anti-spam controls such as grey-listing on your mail server, you should whitelist the sending email address (controlled by `reportfrom` configuration option) to ensure your email is not discarded as spam.
The tagmail.conf file contains a list of tags and email addresses separated by colons. Multiple tags and email addresses can be specified by separating them with commas.

Other settings can also be optionally in puppet.conf to control the email notification settings: `smtpserver`, `smtpport`, `smtphelo`, `sendmail`.

## Reference

This module has been built in direct response to the ticket below:
https://tickets.puppetlabs.com/browse/SERVER-62

It is based on the original [tagmail report processor](https://github.com/puppetlabs/puppet/blob/3.7.3/lib/puppet/reports/tagmail.rb) which is a part of core puppet.

## Limitations

This module should be used only for PE >3.4 or Puppet 3.7 onwards and only if using the JVM on the puppet master. For older versions of Puppet or if using the legacy puppet master on Apache/Rack/Passenger, then the tagmail feature built into the core of Puppet should be used.

## Changelog

* Thomas Linkin <trlinkin@gmail.com> (FM-2223) Fix metadata.json to pass linting
* Thomas Linkin <trlinkin@gmail.com> (FM-2223) Update metadata.json details
* Thomas Linkin <trlinkin@gmail.com> (FM-2223) Add LICENSE file
* James Sweeny <james.sweeny@puppetlabs.com> Merge pull request #1 from trlinkin/add_tests
* Thomas Linkin <trlinkin@gmail.com> (FM-2223) Add unit tests and fixtures
* Thomas Linkin <trlinkin@gmail.com> Set rspec-core < 3.0.0 in Gemfile
* Thomas Linkin <trlinkin@gmail.com> (FM-2223) Add testing skeleton
* Anoop V Kumar <anokun7@gmail.com> documentation of puppet.conf changes
* Anoop V Kumar <anokun7@gmail.com> fixed metadata & added link to the original report processor
* Anoop V Kumar <anokun7@gmail.com> fixed metadata & added link to the original report processor
* Anoop V Kumar <anokun7@gmail.com> metadata summary cannot be more tha 144 chars. Updated license info
* Anoop V Kumar <root@master.puppetlabs.vm> remove comma at end of json
* Anoop V Kumar <root@master.puppetlabs.vm> Cleaned up the README and added metadata.json
* anokun7 <anokun7@users.noreply.github.com> Create README.md
* Anoop V Kumar <root@master.puppetlabs.vm> Removed detach(pid) and added comment about Thread.new
* Anoop V Kumar <root@master.puppetlabs.vm> Removed commented lines
* root <root@master.puppetlabs.vm> Thread.new
* root <root@master.puppetlabs.vm> mail gets sent, using Execute.execute instead of safe_posix_fork

