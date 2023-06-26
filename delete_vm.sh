#!/bin/sh

vm_name=$1
if [ $# != 0 ];then
    virsh destroy s_$vm_name
    virsh undefine s_$vm_name
    rm  -f /dev/vg01/s_$vm_name
    rm -f /data/s_$vm_name.xml
    sed -i "/uxp_demo/"d /root/vm_scripts/vm_info.list
else
    echo "delete vm failure,please enter the args of vm_name!!!"
fi
