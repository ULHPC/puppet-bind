# File::      <tt>params.pp</tt>
# Author::    S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2016 S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team
# License::   Gpl-3.0
#
# ------------------------------------------------------------------------------
# You need the 'future' parser to be able to execute this manifest (that's
# required for the each loop below).
#
# Thus execute this manifest in your vagrant box as follows:
#
#      sudo puppet apply -t --parser future /vagrant/tests/params.pp
#
#

include 'bind::params'

$names = ["ensure", "protocol", "port", "forwarders", "allow_query", "packagename", "utils_packages", "user", "group", "servicename", "processname", "hasstatus", "hasrestart", "chrootdir", "configdir", "configdir_mode", "configfile", "configfile_mode", "configfile_owner", "configfile_group", "localconfigfile", "optionsfile", "initconfigfile", "basedir", "pidfile", "logdir"]

notice("bind::params::ensure = ${bind::params::ensure}")
notice("bind::params::protocol = ${bind::params::protocol}")
notice("bind::params::port = ${bind::params::port}")
notice("bind::params::forwarders = ${bind::params::forwarders}")
notice("bind::params::allow_query = ${bind::params::allow_query}")
notice("bind::params::packagename = ${bind::params::packagename}")
notice("bind::params::utils_packages = ${bind::params::utils_packages}")
notice("bind::params::user = ${bind::params::user}")
notice("bind::params::group = ${bind::params::group}")
notice("bind::params::servicename = ${bind::params::servicename}")
notice("bind::params::processname = ${bind::params::processname}")
notice("bind::params::hasstatus = ${bind::params::hasstatus}")
notice("bind::params::hasrestart = ${bind::params::hasrestart}")
notice("bind::params::chrootdir = ${bind::params::chrootdir}")
notice("bind::params::configdir = ${bind::params::configdir}")
notice("bind::params::configdir_mode = ${bind::params::configdir_mode}")
notice("bind::params::configfile = ${bind::params::configfile}")
notice("bind::params::configfile_mode = ${bind::params::configfile_mode}")
notice("bind::params::configfile_owner = ${bind::params::configfile_owner}")
notice("bind::params::configfile_group = ${bind::params::configfile_group}")
notice("bind::params::localconfigfile = ${bind::params::localconfigfile}")
notice("bind::params::optionsfile = ${bind::params::optionsfile}")
notice("bind::params::initconfigfile = ${bind::params::initconfigfile}")
notice("bind::params::basedir = ${bind::params::basedir}")
notice("bind::params::pidfile = ${bind::params::pidfile}")
notice("bind::params::logdir = ${bind::params::logdir}")

#each($names) |$v| {
#    $var = "bind::params::${v}"
#    notice("${var} = ", inline_template('<%= scope.lookupvar(@var) %>'))
#}
