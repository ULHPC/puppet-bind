# File::      <tt>bind-zone.pp</tt>
# Author::    Sebastien Varrette (<Sebastien.Varrette@uni.lu>)
# Copyright:: Copyright (c) 2011 Sebastien Varrette (www[http://varrette.gforge.uni.lu])
# License::   GPLv3
#
# ------------------------------------------------------------------------------
# = Defines: bind::zone
#
# Adds a custom BIND zone to named.conf.local and set the associated
#
# == Pre-requisites
#
# * The class 'bind' should have been instanciated
#
# == Parameters:
#
# [*ensure*]
#   default to 'present', can be 'absent' (BEWARE: it will remove the associated
#   directory in /var/www) or 'disabled'
#
# [*zone_type*]
#   Type of zone (can be either 'master', 'slave' or 'forward').
#   Default: 'master'
#
# [*masters*]
#   List of master servers by IP, only valid when zone_type = slaves
#   Default: empty array
#
# [*slaves*]
#   List of slave servers by IP, only valid when zone_type = master
#   Default: empty array
#
# [*forwarders*]
#   forwarders defines a list of IP address(es) (and optional port numbers) to
#   which queries will be forwarded.
#   Default: empty array
#
# [*content*]
#  Specify the contents of the zone configuration as a string. Newlines, tabs,
#  and spaces can be specified using the escaped syntax (e.g., \n for a newline)
#
# [*source*]
#  Copy a file as the content of the zone configuration.
#  Uses checksum to determine when a file
#  should be copied. Valid values are either fully qualified paths to files, or
#  URIs. Currently supported URI types are puppet and file.
#  If content was not specified, you are expected to use the source
#
# [*reverse_rr*]
#  Whether or not a Ressources Records (RR) for the reverse resolution is
#  provided. In this case, you are expected to put as name $name for this
#  definition the base IP of the network NOT IN THE REVERSE ORDER. See the
#  example below.
#
# [*add_to_resolver*]
#   add this domain to /etc/resolv.conf, associated to the nameserver
#   '127.0.0.1'. This is not compatible with a reverse resolution i.e. is
#   reverse_rr is true.
#
# == Requires:
#   $content or $source must be set (may be except in 'forward' mode )
#
# == Sample Usage:
#
#    class { 'bind':
#        ensure     => 'present',
#        forwarders => [ '10.28.0.5' ]
#    }
#
#    bind::zone { 'gaia-cluster.uni.lux':
#        source => "puppet:///private/gaia-cluster/db.gaia-cluster.uni.lux",
#        add_to_resolver => true
#    }
#    bind::zone { '10.226':
#        reverse_RR => true,
#        source     => "puppet:///private/gaia-cluster/db.reverse-226.10"
#    }
#
# This will lead to the following files:
#  $> ls /etc/bind/zones
#  gaia-cluster.uni.lux.db  reverse-225.10.db  reverse-226.10.db
#
#  $> cat /etc/resolv.conf
#  # This file is managed by Puppet. DO NOT EDIT.
#  domain gaia-cluster.uni.lux
#  search gaia-cluster.uni.lux
#  nameserver 127.0.0.1
#

# == Warnings
#
# /!\ Always respect the style guide available
# here[http://docs.puppetlabs.com/guides/style_guide]
#
# [Remember: No empty lines between comments and class definition]
#
define bind::zone(
    $ensure     = $bind::ensure,
    $content    = '',
    $source     = '',
    $zone_type  = 'master',
    $masters    = [],
    $slaves     = [],
    $forwarders = [],
    $reverse_rr = false,
    $add_to_resolver = false
)
{
    include bind::params

    # $name is provided by define invocation
    # guid of this entry
    if (! $reverse_rr ) {
        # Classical mode: you define the Ressources Records (RR) for the regular
        # name resolution i.e. from hostname to IP
        $zonename = $name
        $zonefile = "${zonename}.db"
        $priority = 40
    }
    else {
        # Reverse name resolution i.e. from IPs to hostname
        $reverse_ip = inline_template("<%= @name.split('.').reverse.join('.') %>")
        $zonename   = "${reverse_ip}.in-addr.arpa"
        $zonefile   = "reverse-${reverse_ip}.db"
        $priority = 60
    }

    # First checks
    # Ensure the class bind has been instanciated
    if (! defined( Class['bind'] ) ) {
        fail("The class 'bind' is not instancied")
    }

    # Check the 'ensure' parameter
    if ! ($ensure in [ 'present', 'absent' ]) {
        fail("bind::zone 'ensure' parameter must be set to either 'absent' or 'present'")
    }

    if ($bind::ensure != $ensure) {
        if ($bind::ensure == 'present') {
            warning(" bind::ensure (value '${bind::ensure}') differs from the ensure parameter ('${ensure}'): the zone '${zonename} won't be added'")
        }
        else {
            fail("Cannot add the zone '${zonename}' as bind::ensure is NOT set to present")
        }
    }

    # Check the type parameter
    if ! ($zone_type in [ 'master', 'slave', 'forward' ]) {
        fail("bind::zone 'zone_type' parameter must be set to either 'master', 'slave' or 'forward'")
    }
    if ($zone_type in [ 'forward' ]) {
        fail("The BIND zone type ${zone_type} is not yet implemented")
    }

    if (
          ($zone_type == 'slave'  and
          ($masters == [] or $slaves != [] ))
        or
          ($zone_type == 'master' and
          $masters != [])
        )
    {
        fail("Inconsistent use of zone_type (${zone_type}), slaves (${slaves}) and masters (${masters}) parameters")
    }

    # if content is passed, use that, else if source is passed use that
    case $content {
        '': {
            case $source {
                '': {
                    crit('No content nor source have been specified')
                }
                default: { $real_source = $source }
            }
        }
        default: { $real_content = $content }
    }

    # check
    if ($reverse_rr) and ($add_to_resolver) {
        fail("${name}: Cannot have a reverse zone set to be added to /etc/resolv.conf")
    }

    # Let's go
    info("Manage the custom bind zone ${zonename} of type ${zone_type} (with ensure = ${ensure})")

    if ($bind::ensure == 'present') {
        if ($zone_type == 'slave' and $::operatingsystem in [ 'CentOS', 'RedHat' ]) {
            $zone_file_path = "slaves/${zonefile}"
        } else {
            $zone_file_path = "${bind::params::configdir}/zones/${zonefile}"
        }

        concat::fragment { "configure bind zone ${zonename}":
            ensure  => $ensure,
            target  => $bind::params::localconfigfile,
            content => template('bind/custom_zone.erb'),
            order   => $priority,
        }

        if ($zone_type == 'master') {
            file { $zone_file_path:
                owner   => $bind::params::user,
                group   => $bind::params::group,
                mode    => $bind::params::configfile_mode,
                seltype => 'named_zone_t',
                content => $real_content,
                source  => $real_source,
                notify  => Service['bind'],
            }
        }

        if ($add_to_resolver) {
            bind::resolver { $zonename:
                ensure     => $ensure,
                nameserver => '127.0.0.1',
                order      => '01',
                notify     => Service['bind'],
            }
        }

    }
}
