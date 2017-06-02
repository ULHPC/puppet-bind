# File::      <tt>bind-params.pp</tt>
# Author::    Sebastien Varrette (Sebastien.Varrette@uni.lu)
# Copyright:: Copyright (c) 2011 Sebastien Varrette
# License::   GPL v3
#
# ------------------------------------------------------------------------------
# = Class: bind::params
#
# In this class are defined as variables values that are used in other
# bind classes.
# This class should be included, where necessary, and eventually be enhanced
# with support for more OS
#
# == Warnings
#
# /!\ Always respect the style guide available
# here[http://docs.puppetlabs.com/guides/style_guide]
#
# The usage of a dedicated param classe is advised to better deal with
# parametrized classes, see
# http://docs.puppetlabs.com/guides/parameterized_classes.html
#
# [Remember: No empty lines between comments and class definition]
#
class bind::params {

    ######## DEFAULTS FOR VARIABLES USERS CAN SET ##########################
    # (Here are set the defaults, provide your custom variables externally)
    # (The default used is in the line with '')
    ###########################################

    # ensure the presence (or absence) of bind
    $ensure = 'present'

    # The Protocol used. Used by monitor and firewall class. Default is 'tcp'
    $protocol = 'tcp'
    # The port number. Used by monitor and firewall class. The default is 22.
    $port = 53

    # Define global forwarders. Can be an array
    $forwarders = [ '10.21.0.5' ]

    # clients authorized for querying the server; can be an array
    $allow_query = ''

    # enable or disable dnssec, disabled by default
    $dnssec = false

    #### MODULE INTERNAL VARIABLES  #########
    # (Modify to adapt to unsupported OSes)
    #######################################
    # Packages to install
    $packagename = $::operatingsystem ? {
        /(?i-mx:ubuntu|debian)/        => 'bind9',
        /(?i-mx:centos|redhat|fedora)/ => 'bind-chroot',
        default                        => 'bind',
    }
    $utils_packages = $::operatingsystem ? {
        /(?i-mx:ubuntu|debian)/ => [ 'nslint' ],
        default                 => [],
    }

    # The User running bind
    $user = $::operatingsystem ? {
        /(?i-mx:ubuntu|debian)/ => 'bind',
        default                 => 'named',
    }
    $group = $user

    # Bind (aka DNS) service
    $servicename = $::operatingsystem ? {
        /(?i-mx:ubuntu|debian)/        => 'bind9',
        /(?i-mx:centos|redhat|fedora)/ => 'named-chroot',
        default                        => 'named'
    }
    # used for pattern in a service ressource
    $processname = $::operatingsystem ? {
        default => 'named',
    }
    $hasstatus = $::operatingsystem ? {
        /(?i-mx:ubuntu|debian)/        => false,
        /(?i-mx:centos|fedora|redhat)/ => true,
        default => true,
    }
    $hasrestart = $::operatingsystem ? {
        default => true,
    }

    # Chroot dir
    $chrootdir =  $::operatingsystem ? {
        /(?i-mx:ubuntu|debian)/        => '/var/chroot/bind',
        /(?i-mx:centos|fedora|redhat)/ => '/var/named/chroot',
        default                        => '/var/chroot/bind'
    }

    # Configuration directory
    $configdir = $::operatingsystem ? {
        /(?i-mx:ubuntu|debian)/        => "${chrootdir}/etc/bind",
        /(?i-mx:centos|fedora|redhat)/ => '/etc/named',
        default                        => '/etc/bind'
    }
    $configdir_mode = $::operatingsystem ? {
        default => '0755',
    }

    # Bind main configuration file
    $configfile = $::operatingsystem ? {
        /(?i-mx:ubuntu|debian)/        => "${chrootdir}/etc/bind/named.conf",
        /(?i-mx:centos|fedora|redhat)/ => '/etc/named.conf',
        default => '/etc/bind/named.conf'
    }
    $configfile_mode = $::operatingsystem ? {
        default => '0644',
    }

    $configfile_owner = $::operatingsystem ? {
        default => $user,
    }

    $configfile_group = $::operatingsystem ? {
        default => $group,
    }

    # named.conf.local
    $localconfigfile = $::operatingsystem ? {
        default => "${configdir}/named.conf.local"
    }
    # named.conf.default_zones
    $default_zones_file = $::operatingsystem ? {
        default => "${configdir}/named.conf.default-zones"
    }
    # named.conf.options
    $optionsfile = $::operatingsystem ? {
        default => "${configdir}/named.conf.options"
    }

    #init.d default config file
    $initconfigfile = $::operatingsystem ? {
        /(?i-mx:ubuntu|debian)/ => '/etc/default/bind9',
        default => '/etc/sysconfig/named',
    }

    # Base directory for Bind
    $basedir = $::operatingsystem ?  {
        /(?i-mx:ubuntu|debian)/ => '/var/cache/bind',
        default => '/var/named',
    }

    # PID file
    $pidfile = $::operatingsystem ?  {
        /(?i-mx:ubuntu|debian)/        => '/var/run/bind/named.pid',
        /(?i-mx:centos|fedora|redhat)/ => '/run/named/named.pid',
        default                        => '/var/run/named.pid',
    }

    # Log dir (log file will be ${logdir}/bind.log
    $logdir = $::operatingsystem ?  {
        default => '/var/log',
    }

}
