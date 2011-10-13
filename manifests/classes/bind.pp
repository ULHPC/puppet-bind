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
        debian, ubuntu:         { include bind::debian }
        redhat, fedora, centos: { include bind::redhat }
        default: {
            fail("Module $module_name is not supported on $operatingsystem")
        }
    }
}

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
        name    => "${bind::params::packagename}",
        ensure  => "${bind::ensure}",
    }
    package { $bind::params::utils_packages:
        ensure  => "${bind::ensure}",
    }
    
    if ($bind::ensure == 'present') {

        # Create the chroot
        exec { "Creates ${bind::params::chrootdir}":
            command => "mkdir -p ${bind::params::chrootdir}",
            path    => "/usr/bin:/usr/sbin:/bin",
            require => Package['bind']
        }

        # file { "${bind::params::chrootdir}":
        #     owner   => "${bind::params::user}",
        #     group   => "${bind::params::group}",
        #     mode    => '0755',
        #     ensure  => 'directory',
        #     require => Package['bind']
        # }

        exec { 'Populate chroot directory':
            cwd     => "${bind::params::chrootdir}",
            command => "mkdir -p etc/bind dev var/cache/bind var/run/bind/run",
            path    => "/usr/bin:/usr/sbin:/bin",
            require => Exec["Creates ${bind::params::chrootdir}"]
        }

        exec { "create ${bind::params::chrootdir}/dev/null":
            command => "mknod ${bind::params::chrootdir}/dev/null c 1 3 && chmod 666 ${bind::params::chrootdir}/dev/null",
            path    => "/usr/bin:/usr/sbin:/bin",
            creates => "${bind::params::chrootdir}/dev/null",
            require => Exec['Populate chroot directory']
        }

        exec { "create ${bind::params::chrootdir}/dev/random":
            command => "mknod ${bind::params::chrootdir}/dev/random c 1 8 && chmod 666 ${bind::params::chrootdir}/dev/random",
            path    => "/usr/bin:/usr/sbin:/bin",
            creates => "${bind::params::chrootdir}/dev/random",
            require => Exec['Populate chroot directory']
        }

        exec { "Set ownership of ${bind::params::chrootdir}":
            command => "chown -R ${bind::params::user}:${bind::params::group} ${bind::params::chrootdir}",
            path    => "/usr/bin:/usr/sbin:/bin",
            require => [
                        Exec["create ${bind::params::chrootdir}/dev/null"],
                        Exec["create ${bind::params::chrootdir}/dev/random"]
                        ]
        }

        # Now populate the configuration directory with the default files
        file { "${bind::params::configdir}":
            owner   => "${bind::params::user}",
            group   => "${bind::params::group}",
            #mode    => "${bind::params::configdir_mode}",
            ensure  => 'directory',
            source  => "puppet:///modules/bind/default",
            recurse => true,
            recurselimit => 1,
            require => Exec["Set ownership of ${bind::params::chrootdir}"]
        }

        file { "${bind::params::configdir}/zones":
            ensure  => 'directory',
            owner   => "${bind::params::user}",
            group   => "${bind::params::group}",
            mode    => "${bind::params::configdir_mode}",
            require => File["${bind::params::configdir}"],
        }


        # Adapt the named.conf.options files
        file { "${bind::params::optionsfile}":
            ensure  => "${bind::ensure}",
            owner   => "${bind::params::user}",
            group   => "${bind::params::group}",
            mode    => "${bind::params::configfile_mode}",
            content => template("bind/named.conf.options.erb"),
            require => File["${bind::params::configdir}"],
            notify  => Service['bind']
        }

        # Prepare the local zone file
        include concat::setup
        concat { "${bind::params::localconfigfile}":
            warn    => true,
            owner   => "${bind::params::configfile_owner}",
            group   => "${bind::params::configfile_group}",
            mode    => "${bind::params::configfile_mode}",
            require => File["${bind::params::configdir}"],
            notify  => Service['bind']
        }

        # Header of the file
        concat::fragment { "named.conf.local_header":
            target  => "${bind::params::localconfigfile}",
            source  => "puppet:///modules/bind/01-named.conf.local_header",
            ensure  => "${bind::ensure}",
            order   => 01,
        }


        # Footer of the file
        concat::fragment { "named.conf.local_footer":
            target  => "${bind::params::localconfigfile}",
            source  => "puppet:///modules/bind/99-named.conf.local_footer",
            ensure  => "${bind::ensure}",
            order   => 99,
        }

        # Adapt the init.d configuration script to run bind and make it use the
        # chroot directory
        augeas { "${bind::params::initconfigfile}/OPTIONS":
            context => "/files/${bind::params::initconfigfile}",
            changes => "set OPTIONS '\"-u bind -t ${bind::params::chrootdir}\"'",
            onlyif  => "get OPTIONS != '\"-u bind -t ${bind::params::chrootdir}\"'",
            require => Exec['Populate chroot directory'],
            notify  => Service['bind'],
        }

        exec { "mv /etc/bind /etc/bind.old":
            path    => "/usr/bin:/usr/sbin:/bin",
            unless  => "test -d /etc/bind.old",
            require => File["${bind::params::configdir}"]
        }
        file { '/etc/bind':
            ensure  => 'link',
            target  => "${bind::params::configdir}",
            require => Exec["mv /etc/bind /etc/bind.old"]
        }
        # copy the rndc.key
        exec { "cp /etc/bind.old/rndc.key ${bind::params::configdir}/":
            path    => "/usr/bin:/usr/sbin:/bin",
            user    => "${bind::params::user}",
            group   => "${bind::params::group}",
            onlyif  => "test -f /etc/bind.old/rndc.key",
            unless  => "test -f ${bind::params::configdir}/rndc.key",
            require => Exec["mv /etc/bind /etc/bind.old"]
        }
        # copy the bind.keys
        exec { "cp /etc/bind.old/bind.keys ${bind::params::configdir}/":
            path    => "/usr/bin:/usr/sbin:/bin",
            user    => "${bind::params::user}",
            group   => "${bind::params::group}",
            onlyif  => "test -f /etc/bind.old/bind.keys",
            unless  => "test -f ${bind::params::configdir}/bind.keys",
            require => Exec["mv /etc/bind /etc/bind.old"]
        }

        # Release the BIND service
        service { 'bind':
            name       => "${bind::params::servicename}",
            enable     => true,
            ensure     => running,
            hasrestart => "${bind::params::hasrestart}",
            pattern    => "${bind::params::processname}",
            hasstatus  => "${bind::params::hasstatus}",
            require    => Package['bind'],
            notify     => Service['syslog']
            #            subscribe  => File['bind.conf'],
        }
    }
    else {
        exec {"rm -rf ${bind::params::chrootdir}":
            path    => "/usr/bin:/usr/sbin:/bin",
            onlyif  => "test -d ${bind::params::chrootdir}",
            require => Package['bind']
        }
        exec { "rm -f /etc/bind":
            path    => "/usr/bin:/usr/sbin:/bin",
            onlyif  => "test -h /etc/bind",
            require => Exec["rm -rf ${bind::params::chrootdir}"]
        }
        exec { "mv /etc/bind.old /etc/bind":
            path    => "/usr/bin:/usr/sbin:/bin",
            onlyif  => "test -d /etc/bind.old",
            require => Exec["rm -f /etc/bind"]
        }
        exec { "mv /etc/resolv.conf.old /etc/resolv.conf":
            path    => "/usr/bin:/usr/sbin:/bin",
            onlyif  => "test -f /etc/resolv.conf.old",
            require => Exec["mv /etc/bind.old /etc/bind"]
        }
        augeas { "${bind::params::initconfigfile}/OPTIONS":
            context => "/files/${bind::params::initconfigfile}",
            changes => "set OPTIONS '\"-u bind\"'",
            onlyif  => "get OPTIONS != '\"-u bind\"'",
            require => Package['bind']
        }
    }

    # Adapt syslog configuration
    require syslog
    syslog::conf { 'bind-chroot':
        ensure  => "${bind::ensure}",
        content => template("bind/rsyslog.conf.erb")
    }







    # # Configuration file
    # file { 'bind.conf':
    #     path    => "${bind::params::configfile}",
    #     owner   => "${bind::params::configfile_owner}",
    #     group   => "${bind::params::configfile_group}",
    #     mode    => "${bind::params::configfile_mode}",
    #     ensure  => "${bind::ensure}",
    #     #content => template("bind/bindconf.erb"),
    #     #notify  => Service['bind'],
    #     #require => Package['bind'],
    # }


}


# ------------------------------------------------------------------------------
# = Class: bind::debian
#
# Specialization class for Debian systems
class bind::debian inherits bind::common { }

# ------------------------------------------------------------------------------
# = Class: bind::redhat
#
# Specialization class for Redhat systems
class bind::redhat inherits bind::common { }



