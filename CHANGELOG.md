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
