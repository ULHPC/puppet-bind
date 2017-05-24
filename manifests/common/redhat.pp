# File::      <tt>redhat.pp</tt>
# Author::    Sebastien Varrette (Sebastien.Varrette@uni.lu)
# Copyright:: Copyright (c) 2011 Sebastien Varrette
# License::   GPLv3
#
# ------------------------------------------------------------------------------
# = Class: bind::common::redhat
#
# Specialization class for Redhat systems
class bind::common::redhat inherits bind::common {

    if ($bind::ensure == present)
    {
        # copy the bind.keys
        exec { "mv /etc/named.iscdlv.key ${bind::params::configdir}/bind.keys":
            path    => '/usr/bin:/usr/sbin:/bin',
            onlyif  => 'test -f /etc/named.iscdlv.key',
            unless  => "test -f ${bind::params::configdir}/bind.keys",
            require => File[$bind::params::configdir],
            notify  => Service['bind']
        }

        file { '/etc/named.rfc1912.zones':
            ensure => absent,
        }
    }
}
