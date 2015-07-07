# tagmail

#### Table of Contents

1. [Module Description - What the module does and why it is useful](#module-description)
2. [Setup - The basics of getting started with tagmail](#setup)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)
5. [Development - Guide for contributing to the module](#development)


## Module Description

The tagmail module forwards Puppet log messages as email if the log messages relate to resources that have been assigned specific tags. This module provides the same functionality as the tagmail feature previously built into Puppet.

The tagmail module is a [report processor](https://docs.puppetlabs.com/guides/reporting.html) plugin that lets you sort log messages into email reports by pairing particular tags with particular email addresses. This module replaces Puppet's built-in tagmail feature, which is broken in the JVM-based PE 3.7 and completely removed in PE 3.8 and Puppet 4.0.

Tags let you set context for resources, classes, and defines. For example, you can assign a tag to all resources associated with a particular operating system, location, or other characteristic. The tag is then included in all log messages related to those resources. [Read more about tags.](http://docs.puppetlabs.com/puppet/latest/reference/lang_tags.html)

> Note that version 1.x of the tagmail module supports only Puppet 3.7 to 3.8 and PE 3.7 to 3.8.1. For newer versions of Puppet or PE, you must upgrade to tagmail 2.0. For older versions of Puppet, use Puppet's built-in tagmail feature.


## Setup

In `puppet.conf`, make sure `tagmail` is one of the comma-separated values for the `reports` setting, as shown below:

```
[master]
tagmap = $confdir/tagmail.conf
reports = puppetdb,console,tagmail
```

On the agent, make sure the [`pluginsync`](https://docs.puppetlabs.com/references/latest/configuration.html#pluginsync) and [`report`](https://docs.puppetlabs.com/references/latest/configuration.html#report) settings are enabled. (These settings are normally enabled by default.)

```
[agent]
report = true
pluginsync = true
```

If you use anti-spam controls such as grey-listing on your mail server, whitelist Puppet's sending email address (controlled by the `reportfrom` setting in `puppet.conf`) to ensure your tagmail reports are not discarded as spam.

## Usage

To configure the tagmail module, create a file called `tagmail.conf`. The location for this file depends on the `tagmap` option in `puppet.conf`. It defaults to the $confdir directory, and you can check its current value by running `puppet master --configprint tagmap` on the Puppet master.

Each line in `tagmail.conf` should include a comma-separated list of tags, a colon, and a comma-separated list of email addresses to receive log messages containing the provided tags.

If you prefix a tag with an exclamation mark, Puppet subtracts any messages with that tag from the line's results.

Puppet's [loglevels](https://docs.puppetlabs.com/references/latest/metaparameter.html#loglevel) (`debug`, `info`, `notice`, `warning`, `err`, `alert`, `emerg`, `crit`, and `verbose`) can also be used as tags, and the `all` tag always matches every log message.

An example `tagmail.conf`:
~~~
all: me@example.com
webserver, !mailserver: httpadmins@example.com, you@example.com
~~~

The above example sends all log messages to `me@example.com`, and all messages from webservers that are not also from mailservers to `httpadmins@example.com` and to `you@example.com`.

## Limitations

This module should be used only with Puppet Enterprise and Puppet versions 3.7 or newer, and only if you're using the JVM on the Puppet master. For older versions of Puppet, or if using the legacy Puppet master on Apache/Rack/Passenger, use Puppet's built-in tagmail feature.

## Development

Puppet Labs modules on the Puppet Forge are open projects, and community contributions are essential for keeping them great. We can't access the huge number of platforms and myriad hardware, software, and deployment configurations that Puppet is intended to serve. We want to keep it as easy as possible to contribute changes so that our modules work in your environment. There are a few guidelines that we need contributors to follow so that we can have a chance of keeping on top of things.

For more information, see our [module contribution guide.](https://docs.puppetlabs.com/forge/contributing.html)

To see who's already involved, see the [list of contributors.](https://github.com/puppetlabs/puppetlabs-tagmail/graphs/contributors)