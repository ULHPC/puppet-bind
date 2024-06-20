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
    $packagename = $facts['os']['name'] ? {
        /(?i-mx:ubuntu|debian)/              => 'bind9',
        /(?i-mx:centos|redhat|rocky|fedora)/ => 'bind-chroot',
        default                              => 'bind',
    }
    $utils_packages = $facts['os']['name'] ? {
        /(?i-mx:ubuntu|debian)/ => [ 'nslint' ],
        default                 => [],
    }

    # The User running bind
    $user = $facts['os']['name'] ? {
        /(?i-mx:ubuntu|debian)/ => 'bind',
        default                 => 'named',
    }
    $group = $user

    # Bind (aka DNS) service
    $servicename = $facts['os']['name'] ? {
        /(?i-mx:ubuntu|debian)/              => 'bind9',
        /(?i-mx:centos|redhat|rocky|fedora)/ => 'named-chroot',
        default                              => 'named'
    }
    # used for pattern in a service ressource
    $processname = $facts['os']['name'] ? {
        default => 'named',
    }
    $hasstatus = $facts['os']['name'] ? {
        /(?i-mx:ubuntu|debian)/        => false,
        /(?i-mx:centos|fedora|redhat|rocky)/ => true,
        default => true,
    }
    $hasrestart = $facts['os']['name'] ? {
        default => true,
    }

    # Chroot dir
    $chrootdir =  $facts['os']['name'] ? {
        /(?i-mx:ubuntu|debian)/              => '/var/chroot/bind',
        /(?i-mx:centos|fedora|redhat|rocky)/ => '/var/named/chroot',
        default                              => '/var/chroot/bind'
    }

    # Configuration directory
    $configdir = $facts['os']['name'] ? {
        /(?i-mx:ubuntu|debian)/              => "${chrootdir}/etc/bind",
        /(?i-mx:centos|fedora|redhat|rocky)/ => '/etc/named',
        default                              => '/etc/bind'
    }
    $configdir_mode = $facts['os']['name'] ? {
        default => '0755',
    }

    # Bind main configuration file
    $configfile = $facts['os']['name'] ? {
        /(?i-mx:ubuntu|debian)/              => "${chrootdir}/etc/bind/named.conf",
        /(?i-mx:centos|fedora|redhat|rocky)/ => '/etc/named.conf',
        default => '/etc/bind/named.conf'
    }
    $configfile_mode = $facts['os']['name'] ? {
        default => '0644',
    }

    $configfile_owner = $facts['os']['name'] ? {
        default => $user,
    }

    $configfile_group = $facts['os']['name'] ? {
        default => $group,
    }

    # named.conf.local
    $localconfigfile = $facts['os']['name'] ? {
        default => "${configdir}/named.conf.local"
    }
    # named.conf.default_zones
    $default_zones_file = $facts['os']['name'] ? {
        default => "${configdir}/named.conf.default-zones"
    }
    # named.conf.options
    $optionsfile = $facts['os']['name'] ? {
        default => "${configdir}/named.conf.options"
    }

    #init.d default config file
    $initconfigfile = $facts['os']['name'] ? {
        /(?i-mx:ubuntu|debian)/ => '/etc/default/bind9',
        default => '/etc/sysconfig/named',
    }

    # Base directory for Bind
    $basedir = $facts['os']['name'] ?  {
        /(?i-mx:ubuntu|debian)/ => '/var/cache/bind',
        default => '/var/named',
    }

    # PID file
    $pidfile = $facts['os']['name'] ?  {
        /(?i-mx:ubuntu|debian)/              => '/var/run/bind/named.pid',
        /(?i-mx:centos|fedora|redhat|rocky)/ => '/run/named/named.pid',
        default                              => '/var/run/named.pid',
    }

    # Log dir (log file will be ${logdir}/bind.log
    $logdir = $facts['os']['name'] ?  {
        default => '/var/log',
    }

}
