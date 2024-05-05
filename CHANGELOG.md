<!-- markdownlint-disable MD024 -->
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

## [v1.1.0](https://github.com/puppetlabs/puppetlabs-hocon/tree/v1.1.0) - 2019-10-29

[Full Changelog](https://github.com/puppetlabs/puppetlabs-hocon/compare/1.0.1...v1.1.0)

### Added

- (FM-8221) converted to use litmus [#92](https://github.com/puppetlabs/puppetlabs-hocon/pull/92) ([tphoney](https://github.com/tphoney))
- Supported OS Update [#90](https://github.com/puppetlabs/puppetlabs-hocon/pull/90) ([trevor-vaughan](https://github.com/trevor-vaughan))
- pdksync - (MODULES-6805) metadata.json shows support for puppet 6 [#88](https://github.com/puppetlabs/puppetlabs-hocon/pull/88) ([tphoney](https://github.com/tphoney))

### Fixed

- (maint) Resolve config object before manipulating it [#89](https://github.com/puppetlabs/puppetlabs-hocon/pull/89) ([Magisus](https://github.com/Magisus))

## [1.0.1](https://github.com/puppetlabs/puppetlabs-hocon/tree/1.0.1) - 2018-06-21

[Full Changelog](https://github.com/puppetlabs/puppetlabs-hocon/compare/1.0.0...1.0.1)

### Other

- Readme changes made.
- All mentions of this module being supported were removed.

## [1.0.0](https://github.com/puppetlabs/puppetlabs-hocon/tree/1.0.0) - 2017-10-31

[Full Changelog](https://github.com/puppetlabs/puppetlabs-hocon/compare/0.9.4...1.0.0)

### Fixed

- setting and path as namevars for hocon_setting ([HC-30](https://tickets.puppet.com/browse/HC-30))
- support for localization ([MODULES-4528](https://tickets.puppet.com/browse/MODULES-4528))
- lower bound of Puppet support to 4.7.0
- test failures
- specs to reflect new output format ([HC-98](https://tickets.puppet.com/browse/HC-98))

## [0.9.4](https://github.com/puppetlabs/puppetlabs-hocon/tree/0.9.4) - 2016-03-02

[Full Changelog](https://github.com/puppetlabs/puppetlabs-hocon/compare/0.9.3...0.9.4)

### Fixed

- Confine provider based on hocon gem
- Handle changing value from scalar to array
- Handle adding array value when array doesn't exist

## [0.9.3](https://github.com/puppetlabs/puppetlabs-hocon/tree/0.9.3) - 2015-09-24

[Full Changelog](https://github.com/puppetlabs/puppetlabs-hocon/compare/0.9.2...0.9.3)

### Added

- Add support for managing individual array elements via the  value for the  parameter

### Fixed

- Update the hocon gem dependency from 0.9.2 to 0.9.3

## [0.9.2](https://github.com/puppetlabs/puppetlabs-hocon/tree/0.9.2) - 2015-06-30

[Full Changelog](https://github.com/puppetlabs/puppetlabs-hocon/compare/0.9.1...0.9.2)

### Fixed

- Move the logic for saving a modified configuration file out of its own separate class and into the provider. This resolves an issue wherein the hocon gem was sometimes being required when it shouldn't have been, leading to errors.

## [0.9.1](https://github.com/puppetlabs/puppetlabs-hocon/tree/0.9.1) - 2015-05-26

[Full Changelog](https://github.com/puppetlabs/puppetlabs-hocon/compare/0.9.0...0.9.1)

### Fixed

- Allow true numeric values to be set in a configuration file in versions of Puppet prior to 4.0.0.

## [0.9.0](https://github.com/puppetlabs/puppetlabs-hocon/tree/0.9.0) - 2015-04-28

[Full Changelog](https://github.com/puppetlabs/puppetlabs-hocon/compare/2949ddadc2fea633fffa90fe74f4207a4c730a3a...0.9.0)
### Added

- Add support for passing arrays and hashes to the  parameter
- Add support for passing in the exact text of a setting as it is desired to appear in the configuration file under the  setting (useful, for example, if one wants to insert a substitution, or a value with internal comments, such as a map)

### Fixed

- Update the hocon gem dependency to the newly released 0.9.0 version.
- puppetlabs-hocon will no longer change an existing configuration file's ordering, comments, or indentation when modifying or adding settings.


