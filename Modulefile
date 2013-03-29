name    'bind'
version '0.1.3'
source  'git-admin.uni.lu:puppet-repo.git'
author  ' ()'
license 'GPL v3'
summary      'Configure and manage the DNS server (Bind9)'
description  'Configure and manage the DNS server (Bind9)'
project_page 'UNKNOWN'

## List of the classes defined in this module
classes     'bind::params, bind, bind::common, bind::debian, bind::redhat'
## List of the definitions defined in this module
definitions 'concat, syslog'

## Add dependencies, if any:
# dependency 'username/name', '>= 1.2.0'
dependency 'concat' 
dependency 'syslog' 
