# File::      <tt>bind.pp</tt>
# Author::    Sebastien Varrette (Sebastien.Varrette@uni.lu)
# Copyright:: Copyright (c) 2011 Sebastien Varrette
# License::   GPLv3
#
# ------------------------------------------------------------------------------
# = Class: bind
#
# Configure and manage the DNS server (Bind9)
#
# == Parameters:
#
# $ensure:: *Default*: 'present'. Ensure the presence (or absence) of bind
#
# == Actions:
#
# Install and configure bind
#
# == Requires:
#
# n/a
#
# == Sample Usage:
#
#     import bind
#
# You can then specialize the various aspects of the configuration,
# for instance:
#
#         class { 'bind':
#             ensure => 'present'
#         }
#
# == Warnings
#
# /!\ Always respect the style guide available
# here[http://docs.puppetlabs.com/guides/style_guide]
#
#
# [Remember: No empty lines between comments and class definition]
#
class bind(
    $ensure      = $bind::params::ensure,
    $forwarders  = $bind::params::forwarders,
    $allow_query = $bind::params::allow_query
)
inherits bind::params
{
    info ("Configuring bind (aka DNS server) with ensure = ${ensure}")

    if ! ($ensure in [ 'present', 'absent' ]) {
        fail("bind 'ensure' parameter must be set to either 'absent' or 'present'")
    }

    case $::operatingsystem {
        debian, ubuntu:         { include bind::common::debian }
        redhat, fedora, centos: { include bind::common::redhat }
        default: {
            fail("Module ${::module_name} is not supported on ${::operatingsystem}")
        }
    }
}
