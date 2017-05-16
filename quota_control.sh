#!/bin/bash

trigger="50"
from="sender@gmail.com"
target="target@gmail.com"
smtp="smtp.gmail.com:587"
tls="yes"
pass="PasswordOfsender@gmail.com"

# Cek kapasitas harddisk
all_disk_usage=$(df -h)
max_disk_usage=$(df -h | grep / | awk '{ print $5}' | sed 's/%//g' | sort -g | tail -n1)

#Jika ada partisi yang mencapai trigger maka ...
if [ $max_disk_usage -gt $trigger ]
then

	#Kirimkan e-mail berisi status penggunaan harddisk (harus menginstall aplikasi sendemail, bukan sendmail)
	sendEmail -f "$from" -t "$target" -s "$smtp" -o tls="$tls" -xu "$from" -xp "$pass" -u "Disk usage is reaching $trigger percent" -m "$all_disk_usage"

fi

#Membaca semua e-mail account
/opt/zimbra/bin/zmprov -l gaa | while read ACCOUNT
do

	#Menghitung besaran quota tiap inbox e-mail account (satuan bytes)
	quota_total=$(/opt/zimbra/bin/zmprov ga ${ACCOUNT} | grep "zimbraMailQuota" | cut -d ":" -f2 | sed 's/ //g')

	#Jika besaran quota tiap inbox e-mail account tidak sama dengan 0 atau tidak sama dengan unlimited maka ...
	if [ $quota_total -ne 0 ]
	then

		#Mengecek besaran quota dan satuan asalnya
		quota_numeral=$(/opt/zimbra/bin/zmmailbox -z -m ${ACCOUNT} gms | cut -d " " -f1)
		quota_unit=$(/opt/zimbra/bin/zmmailbox -z -m ${ACCOUNT} gms | cut -d " " -f2)
		
		#Menghitung besaran quota yang telah digunakan oleh masing-masing e-mail account (dikonversikan ke bytes dari satuan asalnya)
		case "$quota_unit" in
		"MB")
			quota_numeral=$(echo - | awk '{print $quota_numeral * 1024 * 1024}')
			;;
		"K")
			quota_numeral=$(echo - | awk '{print $quota_numeral * 1024}')
			;;
		esac
			
		#Menghitung prosentase trigger dan menentukan besaran kuota untuk trigger (mengabaikan koma)
		percent_trigger=$((100 / trigger))
		quota_trigger=$(echo - | awk '{print $quota_total / $percent_trigger}' | cut -d "." -f1)
		
		echo "${ACCOUNT}"
		echo "$quota_numeral"
		echo "$quota_trigger"
		
		#Jika ada e-mail account yang mencapai quota trigger maka ...
		if [ "$quota_numeral" -gt "$quota_trigger" ]
		then

			#Menetapkan quota baru sebanyak 2 x quota awal
			new_quota=$((quota_total * 2))
			/opt/zimbra/bin/zmprov ma "${ACCOUNT}" zimbraMailQuota "$new_quota"
			
			#Mengkonversi besaran quota dan total quota kedalam Mega Bytes agar mudah dibaca
			quota_numeral=$((quota_numeral / 1024 / 1024))
			quota_total=$((quota_total / 1024 / 1024))
			
			#Kirimkan e-mail berisi status quota e-mail (harus menginstall aplikasi sendemail, bukan sendmail)
			sendEmail -f "$from" -t "$target" -s "$smtp" -o tls="$tls" -xu "$from" -xp "$pass" -u "User ${ACCOUNT} quota reaching $trigger percent" -m "Current usage is $quota_numeral MB of $quota_total MB"

		fi
		
	fi

done
