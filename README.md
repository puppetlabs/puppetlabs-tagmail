# tagmail

#### Table of Contents

1. [Module description - What the module does and why it is useful](#description)
2. [Setup - The basics of getting started with tagmail](#setup)
   * [Requirements](#requirements)
   * [Beginning with tagmail](#beginning-with-tagmail)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)
5. [Development - Guide for contributing to the module](#development)


## Description

The tagmail module sends Puppet log messages as email if the log messages relate to resources that have been assigned specific tags. This module provides the same functionality as the tagmail feature that was previously built into Puppet.

The tagmail module is a [report processor](https://puppet.com/docs/puppet/latest/reporting_write_processors.html) plugin that lets you sort log messages into email reports by pairing particular tags with particular email addresses. This module replaces Puppet's built-in tagmail feature, which is broken in the JVM-based PE 3.7 and completely removed in PE 3.8 and Puppet 4.0.

> Note that version 1.x of the tagmail module supports only Puppet 3.7 to 3.8 and PE 3.7 to 3.8.1. For newer versions of Puppet or PE, you must upgrade to tagmail 2.0. For older versions of Puppet, use Puppet's built-in tagmail feature.

## Setup

### Requirements

This module supports Puppet Enterprise and Puppet versions 3.8 or newer. For older versions of Puppet, use Puppet's built-in tagmail feature.

### Beginning with tagmail

1. On each Puppet agent, make sure the [`pluginsync`](https://docs.puppet.com/puppet/latest/configuration.html#pluginsync) and [`report`](https://docs.puppet.com/puppet/latest/configuration.html#report) settings are enabled. (These settings are normally enabled by default.)

  ```
[main]
report = true
pluginsync = true
  ```

2. On the Puppet server, include tagmail in the reports setting in the server section:

  ```
[server]
tagmap = $confdir/tagmail.conf
reports = puppetdb,console,tagmail
  ```

3. If you use anti-spam controls such as grey-listing on your mail server, allowlist Puppet's sending email address to ensure your tagmail reports are not discarded as spam. This setting is controlled by the `reportfrom` setting in `puppet.conf`.

4. In the Puppet confdir on your server, create a `tagmail.conf` file. This file will contain your email transport config options, as well as the tags themselves.

## Usage

### Tags

Tags let you set context for resources, classes, and defined types. For example, you can assign a tag to all resources associated with a particular operating system, location, or other characteristic. The tag is then included in all log messages related to those resources.

Puppet's [loglevels](https://docs.puppet.com/puppet/latest/metaparameter.html#loglevel) (`debug`, `info`, `notice`, `warning`, `err`, `alert`, `emerg`, `crit`, and `verbose`) can also be used as tags, and the `all` tag always matches every log message. To learn more about tags, see tags in the Puppet Language docs.

### Configure `tagmail.conf`

To configure the tagmail module, edit the `tagmail.conf` file you created in Step 4 above. This file is located in your Puppet confdir. The `tagmail.conf` should be formatted as an ini file.

1. Open `tagmail.conf` in your text editor and add create `[transport]` and `[tagmap]` sections.

1. In the `[transport]` section, specify _either_:

   * `sendmail`, with a path to your sendmail binary (by default, `/usr/sbin/sendmail`).
   * `smtpserver`, `smtpport`, and `smtphelo`. If you do not specify `smtpserver`, tagmail defaults to using `sendmail`.

1. In the `[tagmap]` section , specify tags and email addresses. Each line should include both:

   * A comma-separated list of tags, ending with a colon
   * A comma-separated list of email addresses to receive log messages for the listed tags. Optionally, exclude any given tag by prefix it with an exclamation mark.

For example, this `tagmail.conf` sends all log messages to `me@example.com`, and all messages from webservers that are *not* also mailservers to `httpadmins@example.com` and to `you@example.com`:

```
[transport]
reportfrom = reports@example.org
smtpserver = smtp.example.org
smtpport = 25
smtphelo = example.org

[tagmap]
all: me@example.com
webserver, !mailserver: httpadmins@example.com, you@example.com
```

If you specify `sendmail` instead of `smtpserver`, it might look like:

```
[transport]
reportfrom = reports@example.org
sendmail = /usr/sbin/sendmail

[tagmap]
all: me@example.com
webserver, !mailserver: httpadmins@example.com, you@example.com
```

## Limitations

For an extensive list of supported operating systems, see [metadata.json](https://github.com/puppetlabs/puppetlabs-tagmail/blob/main/metadata.json)

This module should be used only if you're using the JVM on the Puppet server. For older versions of Puppet, or if using the legacy Puppet server on Apache/Rack/Passenger, use Puppet's built-in tagmail feature.

## Development

Puppet modules on the Puppet Forge are open projects, and community contributions are essential for keeping them great. We can't access the huge number of platforms and myriad hardware, software, and deployment configurations that Puppet is intended to serve. We want to keep it as easy as possible to contribute changes so that our modules work in your environment. There are a few guidelines that we need contributors to follow so that we can have a chance of keeping on top of things.

For more information, see our [module contribution guide.](https://puppet.com/docs/puppet/latest/contributing.html)

To see who's already involved, see the [list of contributors.](https://github.com/puppetlabs/puppetlabs-tagmail/graphs/contributors)
