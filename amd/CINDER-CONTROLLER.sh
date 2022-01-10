#!/bin/bash

read -p "What is openstack passwrd? : " STACK_PASSWD
echo "$STACK_PASSWD"

ifconfig
read -p "Input IP: " SET_IP
echo "$SET_IP"
sync


##########################################
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "cinder Reg. Mariadb ..."
mysql -e "CREATE DATABASE cinder;"
mysql -e "GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'localhost' IDENTIFIED BY '${STACK_PASSWD}';"
mysql -e "GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'%' IDENTIFIED BY '${STACK_PASSWD}';"
mysql -e "FLUSH PRIVILEGES"


##########################################
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "cinder Conf. ..."
. admin-openrc

openstack user create --domain default --password ${STACK_PASSWD} cinder

openstack role add --project service --user cinder admin

openstack service create --name cinderv2 --description "OpenStack Block Storage" volumev2

openstack service create --name cinderv3 --description "OpenStack Block Storage" volumev3

# v2 endpoint 설정
openstack endpoint create --region RegionOne volumev2 public http://controller:8776/v2/%\(project_id\)s

openstack endpoint create --region RegionOne volumev2 internal http://controller:8776/v2/%\(project_id\)s

openstack endpoint create --region RegionOne volumev2 admin http://controller:8776/v2/%\(project_id\)s


# v3 endpoint 설정
openstack endpoint create --region RegionOne volumev3 public http://controller:8776/v3/%\(project_id\)s

openstack endpoint create --region RegionOne volumev3 internal http://controller:8776/v3/%\(project_id\)s

openstack endpoint create --region RegionOne volumev3 admin http://controller:8776/v3/%\(project_id\)s



##########################################
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "cinder DB Conf. ..."
apt install cinder-api -y
apt install cinder-scheduler -y
sync

crudini --set /etc/cinder/cinder.conf database connection mysql+pymysql://cinder:${STACK_PASSWD}@controller/cinder

crudini --set /etc/cinder/cinder.conf DEFAULT transport_url rabbit://openstack:${STACK_PASSWD}@controller
crudini --set /etc/cinder/cinder.conf DEFAULT auth_strategy keystone
crudini --set /etc/cinder/cinder.conf DEFAULT my_ip ${SET_IP}


crudini --set /etc/cinder/cinder.conf keystone_authtoken www_authenticate_uri http://controller:5000
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_url http://controller:5000
crudini --set /etc/cinder/cinder.conf keystone_authtoken memcached_servers controller:11211
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_type auth_type 
crudini --set /etc/cinder/cinder.conf keystone_authtoken project_domain_name default
crudini --set /etc/cinder/cinder.conf keystone_authtoken user_domain_name default
crudini --set /etc/cinder/cinder.conf keystone_authtoken project_name service
crudini --set /etc/cinder/cinder.conf keystone_authtoken username cinder
crudini --set /etc/cinder/cinder.conf keystone_authtoken password ${STACK_PASSWD}

crudini --set /etc/cinder/cinder.conf oslo_concurrency lock_path /var/lib/cinder/tmp


##########################################
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "cinder DB set. ..."

su -s /bin/sh -c "cinder-manage db sync" cinder



##########################################
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "cinder nova set. ..."

crudini --set /etc/nova/nova.conf cinder os_region_name RegionOne


##########################################
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "cinder service ..."
service nova-api restart
service cinder-scheduler restart
service apache2 restart


















