# File::      <tt>common.pp</tt>
# Author::    Sebastien Varrette (Sebastien.Varrette@uni.lu)
# Copyright:: Copyright (c) 2011 Sebastien Varrette
# License::   GPLv3
#
# ------------------------------------------------------------------------------
# = Class: bind::common
#
# Base class to be inherited by the other bind classes
#
# Note: respect the Naming standard provided here[http://projects.puppetlabs.com/projects/puppet/wiki/Module_Standards]
class bind::common {

    # Load the variables used in this module. Check the bind-params.pp file
    require bind::params

    package { 'bind':
        ensure => $bind::ensure,
        name   => $bind::params::packagename,
    }
    package { $bind::params::utils_packages:
        ensure  => $bind::ensure,
    }


    if ($bind::ensure == 'present') {

        if ($facts['os']['selinux']['enabled'] == true) {
            selinux::boolean { 'named_write_master_zones': }
        }


        # Release the BIND service
        service { 'bind':
            ensure     => running,
            name       => $bind::params::servicename,
            enable     => true,
            hasrestart => $bind::params::hasrestart,
            pattern    => $bind::params::processname,
            hasstatus  => $bind::params::hasstatus,
            require    => Package['bind'],
        }

        # Now populate the configuration directory with the default files
        file { $bind::params::configdir:
            ensure => 'directory',
            owner  => $bind::params::user,
            group  => $bind::params::group,
            mode   => $bind::params::configdir_mode,
        }

        # Custom zones directory
        file { "${bind::params::configdir}/zones":
            ensure  => 'directory',
            owner   => $bind::params::user,
            group   => $bind::params::group,
            mode    => $bind::params::configdir_mode,
            require => File[$bind::params::configdir],
        }

        # Adapt the named.conf file
        file { $bind::params::configfile:
            ensure  => $bind::ensure,
            owner   => $bind::params::user,
            group   => $bind::params::group,
            mode    => $bind::params::configfile_mode,
            seltype => 'named_conf_t',
            content => template('bind/named.conf.erb'),
            require => File[$bind::params::configdir],
            notify  => Service['bind'],
        }
        # Adapt the named.conf.options files
        file { $bind::params::optionsfile:
            ensure  => $bind::ensure,
            owner   => $bind::params::user,
            group   => $bind::params::group,
            mode    => $bind::params::configfile_mode,
            seltype => 'named_conf_t',
            content => template('bind/named.conf.options.erb'),
            require => File[$bind::params::configdir],
            notify  => Service['bind'],
        }

        # Prepare the local zone file
        concat { $bind::params::localconfigfile:
            warn    => true,
            owner   => $bind::params::configfile_owner,
            group   => $bind::params::configfile_group,
            mode    => $bind::params::configfile_mode,
            seltype => 'named_conf_t',
            require => File[$bind::params::configdir],
            notify  => Service['bind'],
        }

        # Header of the file
        concat::fragment { 'named.conf.local_header':
            target => $bind::params::localconfigfile,
            source => 'puppet:///modules/bind/01-named.conf.local_header',
            order  => '01',
        }


        # Footer of the file
        concat::fragment { 'named.conf.local_footer':
            target  => $bind::params::localconfigfile,
            content => template('bind/99-named.conf.local_footer.erb'),
            order   => 99,
        }


    }
    else {
        exec { 'rm -f /etc/bind':
            path   => '/usr/bin:/usr/sbin:/bin',
            onlyif => 'test -h /etc/bind',
        }
        exec {"rm -rf ${bind::params::configdir}":
            path   => '/usr/bin:/usr/sbin:/bin',
            onlyif => "test -d ${bind::params::configdir}",
        }
        exec { 'mv /etc/resolv.conf.old /etc/resolv.conf':
            path   => '/usr/bin:/usr/sbin:/bin',
            onlyif => 'test -f /etc/resolv.conf.old',
        }
    }

    if ($bind::params::support_rsyslog == true) {
        # Adapt syslog configuration
        rsyslog::component::custom_config { 'bind-chroot':
            content => template('bind/rsyslog.conf.erb'),
        }
    }

}
