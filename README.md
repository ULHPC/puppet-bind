# Bind Puppet Module

[![Puppet Forge](http://img.shields.io/puppetforge/v/ULHPC/bind.svg)](https://forge.puppetlabs.com/ULHPC/bind)
[![License](http://img.shields.io/:license-GPL3.0-blue.svg)](LICENSE)
![Supported Platforms](http://img.shields.io/badge/platform-debian|redhat|centos-lightgrey.svg)

Configure and manage bind

      Copyright (c) 2026 UL HPC Team <hpc-sysadmins@uni.lu>


| [Project Page](https://github.com/ULHPC/puppet-bind) | [Sources](https://github.com/ULHPC/puppet-bind) | [Issues](https://github.com/ULHPC/puppet-bind/issues) |

## Synopsis

Configure and manage bind.

This module implements the following elements:

* __Puppet classes__:
    - `bind`
    - `bind::common`
    - `bind::common::debian`
    - `bind::common::redhat`
    - `bind::params`

* __Puppet definitions__:
    - `bind::resolver`
    - `bind::zone`

All these components are configured through a set of variables you will find in
[`manifests/params.pp`](manifests/params.pp).

## Dependencies

See [`metadata.json`](metadata.json). In particular, this module depends on

* [puppetlabs/stdlib](https://forge.puppetlabs.com/puppetlabs/stdlib)
* [puppetlabs/concat](https://forge.puppetlabs.com/puppetlabs/concat)
* [puppet/selinux](https://forge.puppetlabs.com/puppet/selinux)
* [ULHPC/syslog](https://forge.puppetlabs.com/ULHPC/syslog)

## Overview and Usage

### Class `bind`

This is the main class defined in this module.
It accepts the following parameters:

* `$ensure`: default to 'present', can be 'absent'

Use it as follows:

        class { 'bind':
            ensure     => 'present',
            forwarders => [ '10.28.0.5' ]
        }

### Definition `bind::resolver`

The definition `bind::resolver` provides ...
This definition accepts the following parameters:

* `$ensure`: default to 'present', can be 'absent'
* `$content`: specify the contents of the directive as a string
* `$source`: copy a file as the content of the directive.

Example:

        bind::resolver { 'uni.lux':
            nameservers => '10.28.0.5',
            order       => 10
        }

### Definition `bind::zone`

The definition `bind::zone` provides ...
This definition accepts the following parameters:

* `$ensure`: default to 'present', can be 'absent'
* `$content`: specify the contents of the directive as a string
* `$source`: copy a file as the content of the directive.

Example:

        bind::zone { 'gaia-cluster.uni.lux':
            source => "puppet:///private/gaia-cluster/db.gaia-cluster.uni.lux",
            add_to_resolver => true
        }

## Librarian-Puppet / R10K Setup

You can of course configure the bind module in your `Puppetfile` to make it available with [Librarian puppet](http://librarian-puppet.com/) or
[r10k](https://github.com/adrienthebo/r10k) by adding the following entry:

     # Modules from the Puppet Forge
     mod "ULHPC/bind"

or, if you prefer to work on the git version:

     mod "ULHPC/bind",
         :git => 'https://github.com/ULHPC/puppet-bind',
         :ref => 'main'


## Developments / Issues / Contributing to the code

This Puppet Module has been implemented in the context of the [UL HPC](http://hpc.uni.lu) Platform of the [University of Luxembourg](http://www.uni.lu).
It relies on [Vox Pupuli modulesync](https://github.com/voxpupuli/modulesync) for its organization.

You can submit bugs / issues / feature requests using the [ULHPC/bind Puppet Module Tracker](https://github.com/ULHPC/puppet-bind/issues).
You are more than welcome to contribute to its development by [sending a pull request](https://help.github.com/articles/using-pull-requests).

## Licence

This project and the sources proposed within this repository are released under the terms of the [GPL-3.0](LICENCE) licence.


[![Licence](https://www.gnu.org/graphics/gplv3-88x31.png)](LICENSE)
