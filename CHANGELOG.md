# Change log

All notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

## [v3.5.0](https://github.com/puppetlabs/puppetlabs-tagmail/tree/v3.5.0) (2020-12-16)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tagmail/compare/v3.4.0...v3.5.0)

### Added

- pdksync - \(feat\) - Add support for Puppet 7 [\#192](https://github.com/puppetlabs/puppetlabs-tagmail/pull/192) ([daianamezdrea](https://github.com/daianamezdrea))

## [v3.4.0](https://github.com/puppetlabs/puppetlabs-tagmail/tree/v3.4.0) (2020-10-23)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tagmail/compare/v3.3.0...v3.4.0)

### Added

- pdksync - \(IAC-973\) - Update travis/appveyor to run on new default branch `main` [\#176](https://github.com/puppetlabs/puppetlabs-tagmail/pull/176) ([david22swan](https://github.com/david22swan))

### Fixed

- \(MODULES-10814\) - Replace `IO.popen` with `Puppet:Util:Execution.execute` [\#182](https://github.com/puppetlabs/puppetlabs-tagmail/pull/182) ([david22swan](https://github.com/david22swan))

## [v3.3.0](https://github.com/puppetlabs/puppetlabs-tagmail/tree/v3.3.0) (2020-07-01)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tagmail/compare/v3.2.0...v3.3.0)

## [v3.2.0](https://github.com/puppetlabs/puppetlabs-tagmail/tree/v3.2.0) (2019-12-09)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tagmail/compare/v3.1.0...v3.2.0)

### Added

- \(FM-8681\) - Addition of Support for CentOS 8 [\#146](https://github.com/puppetlabs/puppetlabs-tagmail/pull/146) ([david22swan](https://github.com/david22swan))

## [v3.1.0](https://github.com/puppetlabs/puppetlabs-tagmail/tree/v3.1.0) (2019-10-15)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tagmail/compare/v3.0.0...v3.1.0)

### Added

- \(IAC-746\) - Add ubuntu 20.04 support [\#171](https://github.com/puppetlabs/puppetlabs-tagmail/pull/171) ([david22swan](https://github.com/david22swan))
- FM-8412 - add support for debian 10 [\#136](https://github.com/puppetlabs/puppetlabs-tagmail/pull/136) ([lionce](https://github.com/lionce))
- \(FM-8231\) convert to use puppet\_litmus [\#134](https://github.com/puppetlabs/puppetlabs-tagmail/pull/134) ([tphoney](https://github.com/tphoney))
- \(FM-8033\) Add RedHat 8 support [\#127](https://github.com/puppetlabs/puppetlabs-tagmail/pull/127) ([eimlav](https://github.com/eimlav))
- Change - Do not send out reports if there are no resources included [\#109](https://github.com/puppetlabs/puppetlabs-tagmail/pull/109) ([blackknight36](https://github.com/blackknight36))

### UNCATEGORIZED PRS; LABEL THEM ON GITHUB

- \(maint\) modulesync 65530a4 Update Travis [\#77](https://github.com/puppetlabs/puppetlabs-tagmail/pull/77) ([michaeltlombardi](https://github.com/michaeltlombardi))

## [v3.0.0](https://github.com/puppetlabs/puppetlabs-tagmail/tree/v3.0.0) (2019-04-25)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tagmail/compare/2.5.0...v3.0.0)

### Changed

- pdksync - \(MODULES-8444\) - Raise lower Puppet bound [\#123](https://github.com/puppetlabs/puppetlabs-tagmail/pull/123) ([david22swan](https://github.com/david22swan))

### Fixed

- checking for logs with level: err [\#117](https://github.com/puppetlabs/puppetlabs-tagmail/pull/117) ([vchepkov](https://github.com/vchepkov))
- pdksync - \(FM-7655\) Fix rubygems-update for ruby \< 2.3 [\#111](https://github.com/puppetlabs/puppetlabs-tagmail/pull/111) ([tphoney](https://github.com/tphoney))

## [2.5.0](https://github.com/puppetlabs/puppetlabs-tagmail/tree/2.5.0) (2018-09-27)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tagmail/compare/2.4.0...2.5.0)

### Added

- pdksync - \(MODULES-6805\) metadata.json shows support for puppet 6 [\#100](https://github.com/puppetlabs/puppetlabs-tagmail/pull/100) ([tphoney](https://github.com/tphoney))
- \(FM-7255\) - Addition of support for Ubuntu 18.04 to tagmail [\#90](https://github.com/puppetlabs/puppetlabs-tagmail/pull/90) ([david22swan](https://github.com/david22swan))

### Fixed

- \[FM-6970\] Removal of unsupported OS from tagmail [\#88](https://github.com/puppetlabs/puppetlabs-tagmail/pull/88) ([david22swan](https://github.com/david22swan))

## 2.4.0
### Summary
This release introduces the PDK to the module - making it PDK compatible.

### Changed
- The module has been cleaned up and had rubocop enabled.
- The module has been fully converted to the PDK.

## 2017-10-06 Supported Release 2.3.0
### Summary
This release is to update the formatting of the module, rubocop having been run for all ruby files and been set to run automatically on all future commits.

### Changed
- Debian 9 has been added to metadata.json
- Rubocop has been implemented.

## 2017-09-19 Supported Release 2.2.1
### Summary
This release is a roll up of changes. The bulk of the changes being module compatibiliity.

### Changed
- Acceptable exit code for module install is 0 only
- Updated puppet version compatibility from 3.7 to 4.7
- Updated puppet boundary from 5.0.0 to 6.0.0
- Changing travis to test on puppet 5 and ruby 2.4
- Updates to readmes/README_ja_JP.md
- Updates to the contributing documentation
- `./lib/**/*.rb` has been added to the locales config

### Removed
- Support for EOL platform Debian 6 (Squeeze)
- Support for EOL for Ubuntu 10.04
- Support for EOL for Ubuntu 12.04

## Supported Release 2.2.0
### Summary

This release adds a new feature and support for internationalization. It also contains Japanese translations for the README, summary and description of the metadata.json and major cleanups in the README. Additional folders have been introduced called locales and readmes where translation files can be found. A number of features and bug fixes are also included in this release.

#### Features
- Addition of POT file / folder structure for i18n.
- Addition of Internationalized READMEs.
- Multiple changes through modulesync, this should not affect the behaviour of the module.
- Update for audit email alerts

## Supported Release 2.1.1
### Summary

Small release for support of newer PE versions. This increments the version of PE in the metadata.json file.

## 2015-07-28 - Supported Release 2.1.0
### Summary

This release includes formal support for Puppet 4.x and Puppet Enterprise 2015.2.x. Additionally, some README improvements have been made.

## 2015-07-07 - Supported Release 2.0.0
### Summary

This is a major release that changes the tagmail.conf configuration file format. As such, this is backwards incompatible with 1.0.0.

## 2015-06-02 - Supported Release 1.0.0
### Summary

The is the initial supported release of the puppetlabs-tagmail module which forwards Puppet log messages via email if they include specific tags. It is a replacement for Puppet's built-in tagmail report processor.

## 2015-02-03 - Release 0.2.0
### Summary

This is the initial release.


\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*
