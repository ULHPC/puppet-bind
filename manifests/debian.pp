# File::      <tt>debian.pp</tt>
# Author::    Sebastien Varrette (Sebastien.Varrette@uni.lu)
# Copyright:: Copyright (c) 2011 Sebastien Varrette
# License::   GPLv3
#
# ------------------------------------------------------------------------------
# = Class: bind::debian
#
# Specialization class for Debian systems
class bind::debian inherits bind::common {

    # Import libssl in chrootdir
    if ($bind::ensure == 'present' and $lsbdistcodename == 'wheezy') {

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
