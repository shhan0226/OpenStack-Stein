#!/bin/bash

read -p "What is openstack passwrd? : " STACK_PASSWD
echo "$STACK_PASSWD"

ifconfig
read -p "Input IP: " SET_IP
echo "$SET_IP"
sync


##########################################
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "cinder install ..."
apt install lvm2 -y
apt install thin-provisioning-tools -y


##########################################
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "cinder Conf. ..."
. admin-openrc

read -p "[GV] Would you like to set it? <y|n>: " VG
sync

if [ "${VG}" = "y" ]; then
#	sudo pvdisplay
#	read -p "pv-name: " PV_NAME
#	echo "$PV_NAME"
#	sync
	sudo vgdisplay
	read -p "vg-name: " VG_NAME
	echo "$VG_NAME"
	sync
fi

##########################################
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "cinder volume. ..."

apt install cinder-volume -y


##########################################
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "cinder conf. ..."

# 환경설정

crudini --set /etc/cinder/cinder.conf database connection mysql+pymysql://cinder:${STACK_PASSWD}@controller/cinder

crudini --set /etc/cinder/cinder.conf DEFAULT transport_url rabbit://openstack:${STACK_PASSWD}@controller
crudini --set /etc/cinder/cinder.conf DEFAULT auth_strategy keystone
crudini --set /etc/cinder/cinder.conf DEFAULT my_ip ${SET_IP}
crudini --set /etc/cinder/cinder.conf DEFAULT enabled_backends lvm
crudini --set /etc/cinder/cinder.conf DEFAULT glance_api_servers http://controller:9292

crudini --set /etc/cinder/cinder.conf keystone_authtoken www_authenticate_uri http://controller:5000
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_url http://controller:5000
crudini --set /etc/cinder/cinder.conf keystone_authtoken memcached_servers controller:11211
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_type password
crudini --set /etc/cinder/cinder.conf keystone_authtoken project_domain_name default
crudini --set /etc/cinder/cinder.conf keystone_authtoken user_domain_name default
crudini --set /etc/cinder/cinder.conf keystone_authtoken project_name service
crudini --set /etc/cinder/cinder.conf keystone_authtoken username cinder
crudini --set /etc/cinder/cinder.conf keystone_authtoken password ${STACK_PASSWD}

crudini --set /etc/cinder/cinder.conf lvm volume_driver cinder.volume.drivers.lvm.LVMVolumeDriver 
crudini --set /etc/cinder/cinder.conf lvm volume_group ${VG_NAME}
crudini --set /etc/cinder/cinder.conf lvm target_protocol iscsi
crudini --set /etc/cinder/cinder.conf lvm target_helper tgtadm

crudini --set /etc/cinder/cinder.conf oslo_concurrency lock_path /var/lib/cinder/tmp


##########################################
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "cinder service. ..."


# 서비스 재시작
service tgt restart
service cinder-volume restart









