#CONF file

####Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with conffile module](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with conffile](#beginning-with-conffile)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
6. [Development - Guide for contributing to the module](#development)

##Overview 

This module adds resource types to manage settings in CONF-style configuration files.

##Module Description

The conffile module adds a resource type so that you can use Puppet to manage settings in HOCON configuration files.

##Setup

##Beginning with conffile

To manage a conf file, add the resource type `conf_setting` to a class.

##Usage

Manage individual settings in CONF files by adding the `conf_setting` resource type to a class. For example:

```
conf_setting { "sample setting":
  ensure  => present,
  path    => '/tmp/foo.conf',
  setting => 'foosetting',
  value   => 'FOO!',
}
```

To control a setting nested within a map contained at another setting, provide the path to that setting
under the "setting" parameter, with each level separated by a ".".

```
foo {
    bar {
        barsetting="FOO!"
    }
}

conf_setting {'sample nested setting':
  ensure  => present,
  path => '/tmp/foo.conf',
  setting => 'foo.bar.barsetting',
  value   => 'BAR!',
}
```

##Reference

###Type: conf_setting

#### Parameters

* `ensure`: Ensures that the resource is present. Valid values are 'present', 'absent'.

* `name`: An arbitrary name used as the identity of the resource.

* `path`: The CONF file in which Puppet will ensure the specified setting.

* `provider`: The specific backend to use for this `conf_setting` resource. You will seldom need to specify this --- Puppet will usually discover the appropriate provider for your platform. The only available provider for `conf_setting` is ruby.

* `setting`: The name of the CONF file setting to be defined.

* `value`: The value of the CONF file setting to be defined.

##Development
 
Puppet Labs modules on the Puppet Forge are open projects, and community contributions are essential for keeping them great. We can’t access the huge number of platforms and myriad of hardware, software, and deployment configurations that Puppet is intended to serve.

We want to keep it as easy as possible to contribute changes so that our modules work in your environment. There are a few guidelines that we need contributors to follow so that we can have a chance of keeping on top of things.

You can read the complete module contribution guide on the [Puppet Labs wiki](http://projects.puppetlabs.com/projects/module-site/wiki/Module_contributing).

##Contributors

The list of contributors can be found at: [https://github.com/puppetlabs/puppetlabs-conffile/graphs/contributors/contributors](https://github.com/puppetlabs/puppetlabs-conffile/graphs/contributors/contributors).




