#!/bin/bash

read -p "What is openstack passwrd? : " STACK_PASSWD
echo "$STACK_PASSWD"

ifconfig
read -p "Input IP: " SET_IP
echo "$SET_IP"
sync

read -p "Input Contorller IP: (ex.192.168.0.2) " CON_IP
echo ${CON_IP}
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
sduo fdisk -l
sudo pvdisplay
sudo vgdisplay
read -p "[LVM-PV] Would you like to set it? <y|n>: " PV
sync

if [ "${PV}" = "y" ]; then	
	read -p "pv-name: " PV_NAME
	echo "$PV_NAME"
	pvcreate $PV_NAME
	sudo pvdisplay
	sync
else
	sudo pvdisplay
fi


read -p "[LVM-VG] Would you like to set it? <y|n>: " VG
sync

if [ "${VG}" = "y" ]; then	
	sudo vgdisplay
	read -p "pg-name: " PV_NAME
	echo "$PV_NAME"
	vgcreate cinder-volumes $PV_NAME
	sudo vgdisplay
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

crudini --set /etc/cinder/cinder.conf database connection mysql+pymysql://cinder:${STACK_PASSWD}@${CON_IP}/cinder

crudini --set /etc/cinder/cinder.conf DEFAULT transport_url rabbit://openstack:${STACK_PASSWD}@${CON_IP}
crudini --set /etc/cinder/cinder.conf DEFAULT auth_strategy keystone
crudini --set /etc/cinder/cinder.conf DEFAULT my_ip ${SET_IP}
crudini --set /etc/cinder/cinder.conf DEFAULT enabled_backends lvm
crudini --set /etc/cinder/cinder.conf DEFAULT glance_api_servers http://${CON_IP}:9292

crudini --set /etc/cinder/cinder.conf keystone_authtoken www_authenticate_uri http://${CON_IP}:5000
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_url http://${CON_IP}:5000
crudini --set /etc/cinder/cinder.conf keystone_authtoken memcached_servers ${CON_IP}:11211
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_type password
crudini --set /etc/cinder/cinder.conf keystone_authtoken project_domain_name default
crudini --set /etc/cinder/cinder.conf keystone_authtoken user_domain_name default
crudini --set /etc/cinder/cinder.conf keystone_authtoken project_name service
crudini --set /etc/cinder/cinder.conf keystone_authtoken username cinder
crudini --set /etc/cinder/cinder.conf keystone_authtoken password ${STACK_PASSWD}

crudini --set /etc/cinder/cinder.conf lvm volume_driver cinder.volume.drivers.lvm.LVMVolumeDriver 
crudini --set /etc/cinder/cinder.conf lvm volume_group cinder-volumes
crudini --set /etc/cinder/cinder.conf lvm target_protocol iscsi
crudini --set /etc/cinder/cinder.conf lvm target_helper tgtadm

crudini --set /etc/cinder/cinder.conf oslo_concurrency lock_path /var/lib/cinder/tmp


##########################################
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "cinder service. ..."


# 서비스 재시작
service tgt restart
service cinder-volume restart

