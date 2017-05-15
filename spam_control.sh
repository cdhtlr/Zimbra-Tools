#!/bin/bash

lower_trigger="10"
higher_trigger="20"
suspected_spam_trigger="100"
from="sendermail@gmail.com"
target="targetmail@gmail.com"
smtp="smtp.gmail.com:587"
tls="yes"
pass="PasswordOfsendermail@gmail.com"
subject="Your subject ex:You have got enemies"
domain="@domain.com"

#Isi dari statistik zimbra
all_count=$(/opt/zimbra/libexec/zmqstat)

#Menghitung e-mail yang tertunda dan aktif di dalam queue
deferred_count=$(/opt/zimbra/libexec/zmqstat | grep "deferred" | sed -n -e "=")
active_count=$(/opt/zimbra/libexec/zmqstat | grep "active" | sed -n -e "=")

#Jika jumlah e-mail yang tertunda atau aktif di dalam queue > lower_trigger e-mail maka ...
if [ $deferred_count -gt $lower_trigger ] || [ $active_count -gt $lower_trigger ]
then

	#Kirimkan e-mail berisi statistik zimbra (harus menginstall aplikasi sendemail, bukan sendmail)
	sendEmail -f "$from" -t "$target" -s "$smtp" -o tls="$tls" -xu "$from" -xp "$pass" -u "$subject" -m "$all_count"

	#Jika jumlah e-mail yang tertunda atau aktif di dalam queue > higher_trigger e-mail maka ...
	if [ $deferred_count -gt $higher_trigger ] || [ $active_count -gt $higher_trigger ]
	then
		
		#Pendataan alamat e-mail yang dianggap nyepam
		suspected_email=$(/opt/zimbra/common/sbin/postqueue -p | grep "$domain" | cut -d " " -f10 | grep "$domain" | sort -u)
		
		#Untuk setiap e-mail yang dianggap nyepam
		for i in $suspected_email
		do
			
			#Dihitung jumlah e-mailnya
			suspected_spam_count=$(/opt/zimbra/common/sbin/postqueue -p | grep "$i" | wc -l)
			
			#Jika jumlah email dari alamat yang dianggap nyepam > suspected_spam_trigger maka ...
			if [ $suspected_spam_count -gt $suspected_spam_trigger ]
			then
			
				#Buat password baru
				new_password=$(od -vAn -N4 -tu4 < /dev/urandom)
				
				#Ganti password dengan password yang baru
				/opt/zimbra/bin/zmprov sp "$i" "$new_password"
				
				#Tahan semua e-email dari alamat e-mail yang terindikasi sebagai spammer
				/opt/zimbra/common/sbin/postqueue -p | awk 'BEGIN { RS = "" } { if ($7 == "$i" ) print $1 }' | tr -d '!*' | postsuper -h -
			fi
		done
	fi
fi
