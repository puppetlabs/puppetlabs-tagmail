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
