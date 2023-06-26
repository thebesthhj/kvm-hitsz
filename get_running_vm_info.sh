#!/bin/bash 

#ping当前网段内在线的主机,以便产生arp记录. 
subnet=`route -n|grep "UG" |awk '{print $2}'|sed 's/..$//g'` 
for ip in $subnet.{1..253};do 
{ 
	ping -c1 $ip >/dev/null 2>&1 
}& 
done 

#依次查找arp记录. 
running_vms=`virsh list |grep running` 
shutoff_vms=`virsh list --all|grep -vE "Id|--|running|^$"`

#printf "%-20s %-15s %-20s %-15s %-15s\n" 虚拟机名称 IP地址 cpu核数 内存 状态
printf "虚拟机名称|IP地址|cpu核数|内存|操作系统|状态\n"
for vm_name in `virsh list --all|grep -vE "Id|--|^$"| awk '{ print $2 }'`;do 
    mac=`virsh dumpxml $vm_name |grep "mac address"|sed "s/.*'\(.*\)'.*/\1/g"` 
    vcpu=`virsh dominfo $vm_name| grep "CPU："| awk '{print $2}'`
    memory=`virsh dominfo $vm_name| grep "使用的内存"| awk '{print $2}'`
    ip=`arp -ne |grep "$mac" |awk '{printf $1}'`
    name=`echo $vm_name|awk -F "s_" '/^s_/ {print $2}'`
    os_type=`cat /root/vm_scripts/vm_info.list | grep ${vm_name#*_}|head -n 1 |awk '{print $5}'`
    if [[ `virsh list |grep running|awk '{ print $2 }'|grep $name` != "" ]];then
	#printf "%-15s %-15s %-15s %-15s %-30s\n" $vm_name $ip $vcpu $memory running
	printf "$name|$ip|$vcpu|$memory|$os_type|running\n"
    else
	#printf "%-15s %-15s %-15s %-15s %-30s\n" $vm_name " " $vcpu $memory shut_off
	printf "$name| |$vcpu|$memory|$os_type|shut_off\n"
    fi
done > /root/vm_scripts/vm_list 
if [[ `cat /root/vm_scripts/vm_list` == "" ]];then
    echo "#|#|#|#|#|#" > /root/vm_scripts/vm_list
fi
cat /root/vm_scripts/vm_list
#echo `arp -ne|grep "192.168.224.2"`
echo -ne "\n一共有`virsh list --all|grep -vE "Id|--|^$"|wc -l`个虚拟机,`echo "$running_vms"|grep -v "^$"|wc -l`个虚拟机在运行,`echo "$shutoff_vms"|grep -v "^$"|wc -l`个虚拟机关机.\n"


