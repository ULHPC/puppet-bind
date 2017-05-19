# File::      <tt>debian.pp</tt>
# Author::    Sebastien Varrette (Sebastien.Varrette@uni.lu)
# Copyright:: Copyright (c) 2011 Sebastien Varrette
# License::   GPLv3
#
# ------------------------------------------------------------------------------
# = Class: bind::common::debian
#
# Specialization class for Debian systems
class bind::common::debian inherits bind::common {

    # copy the bind.keys
    exec { "cp /etc/bind.old/bind.keys ${bind::params::configdir}/":
        path    => '/usr/bin:/usr/sbin:/bin',
        user    => $bind::params::user,
        group   => $bind::params::group,
        onlyif  => 'test -f /etc/bind.old/bind.keys',
        unless  => "test -f ${bind::params::configdir}/bind.keys",
        require => Exec['mv /etc/bind /etc/bind.old']
    }


    if ($bind::ensure == 'present') {

        # Create the chroot
        exec { "Creates ${bind::params::chrootdir}":
            command => "mkdir -p ${bind::params::chrootdir}",
            path    => '/usr/bin:/usr/sbin:/bin',
            require => Package['bind']
        }

        exec { 'Populate chroot directory':
            cwd     => $bind::params::chrootdir,
            command => 'mkdir -p etc/bind dev var/cache/bind var/run/bind/run',
            path    => '/usr/bin:/usr/sbin:/bin',
            require => Exec["Creates ${bind::params::chrootdir}"]
        }

        exec { "create ${bind::params::chrootdir}/dev/null":
            command => "mknod ${bind::params::chrootdir}/dev/null c 1 3 && chmod 666 ${bind::params::chrootdir}/dev/null",
            path    => '/usr/bin:/usr/sbin:/bin',
            creates => "${bind::params::chrootdir}/dev/null",
            require => Exec['Populate chroot directory']
        }

        exec { "create ${bind::params::chrootdir}/dev/random":
            command => "mknod ${bind::params::chrootdir}/dev/random c 1 8 && chmod 666 ${bind::params::chrootdir}/dev/random",
            path    => '/usr/bin:/usr/sbin:/bin',
            creates => "${bind::params::chrootdir}/dev/random",
            require => Exec['Populate chroot directory']
        }

        exec { "Set ownership of ${bind::params::chrootdir}":
            command => "chown -R ${bind::params::user}:${bind::params::group} ${bind::params::chrootdir}",
            path    => '/usr/bin:/usr/sbin:/bin',
            require => [
                        Exec["create ${bind::params::chrootdir}/dev/null"],
                        Exec["create ${bind::params::chrootdir}/dev/random"]
                        ]
        } -> File[$bind::params::configdir]


        # Adapt the init.d configuration script to run bind and make it use the
        # chroot directory
        augeas { "${bind::params::initconfigfile}/OPTIONS":
            context => "/files/${bind::params::initconfigfile}",
            changes => "set OPTIONS '\"-u ${bind::params::user} -t ${bind::params::chrootdir} -c ${bind::params::configfile}\"'",
            onlyif  => "get OPTIONS != '\"-u ${bind::params::user} -t ${bind::params::chrootdir} -c ${bind::params::configfile}\"'",
            require => Exec['Populate chroot directory'],
            notify  => Service['bind'],
        }

        exec { 'mv /etc/bind /etc/bind.old':
            path    => '/usr/bin:/usr/sbin:/bin',
            unless  => 'test -d /etc/bind.old \\&& test \\! -d /etc/bind',
            require => File[$bind::params::configdir]
        }
        file { '/etc/bind':
            ensure  => 'link',
            target  => $bind::params::configdir,
            require => Exec['mv /etc/bind /etc/bind.old']
        }
        # copy the rndc.key
        exec { "cp /etc/bind.old/rndc.key ${bind::params::configdir}/":
            path    => '/usr/bin:/usr/sbin:/bin',
            user    => $bind::params::user,
            group   => $bind::params::group,
            onlyif  => 'test -f /etc/bind.old/rndc.key',
            unless  => "test -f ${bind::params::configdir}/rndc.key",
            require => Exec['mv /etc/bind /etc/bind.old']
        }
    }
    else {
        exec { 'mv /etc/bind.old /etc/bind':
            path    => '/usr/bin:/usr/sbin:/bin',
            onlyif  => 'test -d /etc/bind.old',
            require => Exec['rm -f /etc/bind']
        }

        exec {"rm -rf ${bind::params::chrootdir}":
            path    => '/usr/bin:/usr/sbin:/bin',
            onlyif  => "test -d ${bind::params::chrootdir}",
        }
    }

    # Import libssl in chrootdir
    if ($bind::ensure == 'present' and $::lsbdistcodename == 'wheezy') {

        exec { "Create ${bind::params::chrootdir}/usr/lib/x86_64-linux-gnu":
            command => "mkdir -p ${bind::params::chrootdir}/usr/lib/x86_64-linux-gnu",
            path    => '/usr/bin:/usr/sbin:/bin',
            unless  => "test -d ${bind::params::chrootdir}/usr/lib/x86_64-linux-gnu",
            require => Exec['Populate chroot directory']
        }
        exec { "Import libssl in ${bind::params::chrootdir}":
            command => "cp -R /usr/lib/x86_64-linux-gnu/openssl-1.0.0 ${bind::params::chrootdir}/usr/lib/x86_64-linux-gnu/",
            path    => '/usr/bin:/usr/sbin:/bin',
            unless  => "test -d ${bind::params::chrootdir}/usr/lib/x86_64-linux-gnu/openssl-1.0.0",
            require => Exec["Create ${bind::params::chrootdir}/usr/lib/x86_64-linux-gnu"]
        }

        Service['bind'] {
            require => [ Package['bind'], Exec["Import libssl in ${bind::params::chrootdir}"] ]
        }
    }

}
