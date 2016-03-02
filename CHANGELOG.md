## 0.9.4

This is a bugfix release.
* Confine provider based on hocon gem 
* Handle changing value from scalar to array
* Handle adding array value when array doesn't exist

## 0.9.3

This is a feature release.
* Update the hocon gem dependency from 0.9.2 to 0.9.3
* Add support for managing individual array elements via the `array_element`
  value for the `type` parameter

## 0.9.2

This is a minor bugfix release.
* Move the logic for saving a modified configuration file out of its own
  separate class and into the provider. This resolves an issue wherein
  the hocon gem was sometimes being required when it shouldn't have been,
  leading to errors.

## 0.9.1

This is a minor bugfix release.
* Allow true numeric values to be set in a configuration file in versions
  of Puppet prior to 4.0.0.

## 0.9.0

This is a major feature release.
* Update the hocon gem dependency to the newly released 0.9.0 version.
* puppetlabs-hocon will no longer change an existing configuration file's
  ordering, comments, or indentation when modifying or adding settings.
* Add support for passing arrays and hashes to the `value` parameter
* Add support for passing in the exact text of a setting as it is
  desired to appear in the configuration file under the `value`
  setting (useful, for example, if one wants to insert a substitution,
  or a value with internal comments, such as a map)
