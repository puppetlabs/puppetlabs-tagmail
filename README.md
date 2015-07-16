# tagmail

#### Table of Contents

1. [Module Description - What the module does and why it is useful](#module-description)
2. [Setup - The basics of getting started with tagmail](#setup)
  * [Requirements](#requirements)
  * [Beginning with tagmail](#beginning-with-tagmail)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)
5. [Development - Guide for contributing to the module](#development)


## Module Description

The tagmail module forwards Puppet log messages as email if the log messages relate to resources that have been assigned specific tags.
 
This module replaces the Puppet tagmail feature, which was removed as of Puppet Enterprise 3.8.0 and open source Puppet 4.0. This module supports Puppet Enterprise 3.8 and later and open source Puppet 4.0 and later. If you are using older versions of Puppet or Puppet Enterprise, you should use the tagmail feature included in those versions. 

The tagmail module is a [report processor](https://docs.puppetlabs.com/guides/reporting.html) plugin that lets you sort log messages into email reports by pairing particular tags with particular email addresses. Tags let you set context for resources, classes, and defines. For example, you can assign a tag to all resources associated with a particular operating system, location, or other characteristic. The tag is then included in all log messages related to those resources. [Read more about tags.](http://docs.puppetlabs.com/puppet/latest/reference/lang_tags.html)

## Setup

###Requirements

This module supports Puppet Enterprise and Puppet versions 3.8 or newer. For older versions of Puppet, use Puppet's built-in tagmail feature.

###Beginning with tagmail

1. On each Puppet agent, make sure the [`pluginsync`](https://docs.puppetlabs.com/references/latest/configuration.html#pluginsync) and [`report`](https://docs.puppetlabs.com/references/latest/configuration.html#report) settings are enabled. (These settings are normally enabled by default.)

        [agent]
        report = true
        pluginsync = true

2. On the Puppet master, make sure the [`reports`](https://docs.puppetlabs.com/references/4.2.latest/configuration.html#reports) setting in the master section includes tagmail:

        [master]
        reports = tagmail

3. If you use anti-spam controls such as greylisting on your mail server, be sure to whitelist Puppet's sending email address to ensure your tagmail reports are not discarded as spam.

4. In your Puppet confdir on your master, create a tagmail.conf file. This file will contain your email transport config options, as well as the tags themselves.

## Usage

To configure the tagmail module, edit (or create and edit) the `tagmail.conf` in your Puppet confdir.

`tagmail.conf` is formatted as an ini file and is formatted like so:

~~~
[transport]
reportfrom = reports@example.org
smptserver = smtp.example.org
smtpport = 25
smtphelo = example.org

[tagmap]
all: me@example.com
webserver, !mailserver: httpadmins@example.com, you@example.com
~~~

Instead of specifying `smtpserver`, `smtpport` and `smtphelo`, you can specify the `sendmail` option with a path to your sendmail binary (defaulted to `/usr/sbin/sendmail`). If you do not specify `smtpserver`, tagmail will default to using sendmail.

~~~
[transport]
reportfrom = reports@example.org
sendmail = /usr/sbin/sendmail

[tagmap]
all: me@example.com
webserver, !mailserver: httpadmins@example.com, you@example.com
~~~

Each line in the `[tagmap]` section of `tagmail.conf` should include a comma-separated list of tags, a colon, and a comma-separated list of email addresses to receive log messages containing the provided tags.

If you prefix a tag with an exclamation mark, Puppet subtracts any messages with that tag from the line's results.

Puppet's [loglevels](https://docs.puppetlabs.com/references/latest/metaparameter.html#loglevel) (`debug`, `info`, `notice`, `warning`, `err`, `alert`, `emerg`, `crit`, and `verbose`) can also be used as tags, and the `all` tag always matches every log message.

The above example sends all log messages to `me@example.com`, and all messages from webservers that are not also from mailservers to `httpadmins@example.com` and to `you@example.com`.


## Limitations

This module supports Puppet Enterprise and Puppet versions 3.8 or newer. For older versions of Puppet, use Puppet's built-in tagmail feature.


## Development

Puppet Labs modules on the Puppet Forge are open projects, and community contributions are essential for keeping them great. We can't access the huge number of platforms and myriad hardware, software, and deployment configurations that Puppet is intended to serve. We want to keep it as easy as possible to contribute changes so that our modules work in your environment. There are a few guidelines that we need contributors to follow so that we can have a chance of keeping on top of things.

For more information, see our [module contribution guide.](https://docs.puppetlabs.com/forge/contributing.html)

To see who's already involved, see the [list of contributors.](https://github.com/puppetlabs/puppetlabs-tagmail/graphs/contributors)
