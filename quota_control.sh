#!/bin/bash

trigger="50"
from="sendermail@gmail.com"
target="targetmail@gmail.com"
smtp="smtp.gmail.com:587"
tls="yes"
pass="PasswordOfsendermail@gmail.com"

# Cek kapasitas harddisk
all_disk_usage=$(df -h)
max_disk_usage=$(df -h | grep / | awk '{ print $5}' | sed 's/%//g' | sort -g | tail -n1)

#Jika ada partisi yang mencapai trigger maka ...
if [ $max_disk_usage -gt $trigger ]
then
	
	#Kirimkan e-mail berisi status penggunaan harddisk (harus menginstall aplikasi sendemail, bukan sendmail)
	sendEmail -f "$from" -t "$target" -s "$smtp" -o tls="$tls" -xu "$from" -xp "$pass" -u "Disk usage reaching $trigger percent" -m "$all_disk_usage"

fi

#Membaca semua e-mail account
zmprov -l gaa | while read ACCOUNT
do
	
	#Menghitung besaran quota tiap inbox e-mail account
	quota_total=$(/opt/zimbra/bin/zmprov ga ${ACCOUNT} | grep "zimbraMailQuota" | cut -d ":" -f2 | sed 's/ //g')
	quota_usage=$(/opt/zimbra/bin/zmmailbox -z -m ${ACCOUNT} gms | awk '{ print $1}')
	quota_trigger=$quota_total / 1048576 * ($trigger / 100)
	
	#Jika ada e-mail account yang mencapai quota trigger maka ...
	if [ $quota_usage -gt $quota_trigger ]
	then
		
		#Kirimkan e-mail berisi status quota e-mail (harus menginstall aplikasi sendemail, bukan sendmail)
		sendEmail -f "$from" -t "$target" -s "$smtp" -o tls="$tls" -xu "$from" -xp "$pass" -u "User ${ACCOUNT} quota reaching $trigger percent" -m "Current usage is $quota_usage of $quota_total"
		
		#menetapkan quota baru sebanyak 2 x quota awal
		new_quota=$quota_total*2
		/opt/zimbra/bin/zmprov ma "${ACCOUNT}" zimbraMailQuota "$new_quota"
		
	fi
done
