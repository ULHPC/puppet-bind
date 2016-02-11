# File::      <tt>bind-resolver.pp</tt>
# Author::    Sebastien Varrette (<Sebastien.Varrette@uni.lu>)
# Copyright:: Copyright (c) 2011 Sebastien Varrette (www[http://varrette.gforge.uni.lu])
# License::   GPLv3
#
# ------------------------------------------------------------------------------
# = Defines: bind::resolver
#
# update the content of /etc/resolv.conf
#
# == Pre-requisites
#
# * The class 'bind' should have been instanciated
#
# == Parameters:
#
# $name corresponds to the domain considered.
#
# [*ensure*]
#   default to 'present', can be 'absent' (BEWARE: it will remove the associated
#   directory in /etc/resolv.conf)
#
# [*nameserver*]
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
#    bind::resolver { 'gaia-cluster.uni.lux':
#        nameservers => '127.0.0.1',
#        order       => 01
#    }
#    bind::resolver { 'uni.lux':
#        nameservers => '10.28.0.5',
#        order       => 10
#    }
#
# This will create the following /etc/resolv.conf
#
#
#

# == Warnings
#
# /!\ Always respect the style guide available
# here[http://docs.puppetlabs.com/guides/style_guide]
#
# [Remember: No empty lines between comments and class definition]
#
define bind::resolver(
    $nameserver = '',
    $order      = '10',
    $ensure     = 'present'
)
{
    include bind::params

    # $name is provided by define invocation
    # guid of this entry
    $domain_name = $name

    # First checks
    if (! defined( Concat['/etc/resolv.conf'] ) ) {
        # backup resolv.conf
        exec { "cp /etc/resolv.conf /etc/resolv.conf.old":
            path   => "/usr/bin:/usr/sbin:/bin",
            unless => "test -f /etc/resolv.conf.old",
            notify => Concat['/etc/resolv.conf']
        }

        include concat::setup
        concat { '/etc/resolv.conf':
            warn    => true,
            owner   => 'root',
            group   => 'root',
            mode    => '0644',
        }
    }

    # Check the 'ensure' parameter
    if ! ($ensure in [ 'present', 'absent' ]) {
        fail("bind::resolver 'ensure' parameter must be set to either 'absent' or 'present'")
    }

    concat::fragment { "/etc/resolv.conf_${domain_name}":
        target  => '/etc/resolv.conf',
        content => template("bind/resolv.conf.part.erb"),
        ensure  => "${ensure}",
        order   => "${order}",
    }


}
