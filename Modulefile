name    'bind'
version '0.1.1'
source  'git-admin.uni.lu:puppet-repo.git'
author  'Hyacinthe Cartiaux (hyacinthe.cartiaux@uni.lu)'
license 'GPL v3'
summary      'Configure and manage the DNS server (Bind9)'
description  'Configure and manage the DNS server (Bind9)'
project_page 'UNKNOWN'

## List of the classes defined in this module
classes     'bind, bind::common, bind::debian, bind::redhat, bind::params'
## List of the definitions defined in this module
definitions 'concat, syslog'

## Add dependencies, if any:
# dependency 'username/name', '>= 1.2.0'
dependency 'concat' 
dependency 'syslog' 
