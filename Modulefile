name       'bind'
version    '0.0.3'
source     'git-admin.uni.lu:puppet-repo.git'
author     'Sebastien Varrette (Sebastien.Varrette@uni.lu)'
license    'GPL v3'
summary    'Configure and manage the DNS server (Bind9)'
description 'Configure and manage the DNS server (Bind9)'
project_page 'UNKNOWN'

## List of the classes defined in this module
classes    'bind::params, bind, bind::common, bind::debian, bind::redhat'

## Add dependencies, if any:
# dependency 'username/name', '>= 1.2.0'
dependency 'concat'
dependency 'syslog'
defines    '["bind::resolver", "bind::zone"]'
