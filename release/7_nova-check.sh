#!/bin/bash

##################################
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "DB REG. ..."

#. admin-openrc
export OS_PROJECT_DOMAIN_NAME=Default
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=stack
export OS_AUTH_URL=http://controller:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2

nova-manage cell_v2 discover_hosts
su -s /bin/sh -c "nova-manage cell_v2 discover_hosts --verbose" nova

crudini --set /etc/nova/nova.conf scheduler discover_hosts_in_cells_interval 300


##################################
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "Node Check ..."

#. admin-openrc
export OS_PROJECT_DOMAIN_NAME=Default
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=stack
export OS_AUTH_URL=http://controller:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2

openstack compute service list
openstack catalog list
openstack image list

nova-status upgrade check

