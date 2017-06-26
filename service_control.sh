#!/bin/bash

from="sendermail@gmail.com"
target="targetmail@gmail.com"
smtp="smtp.gmail.com:587"
tls="yes"
pass="PasswordOfsendermail@gmail.com"
subject="Your subject ex:Zimbra service(s) is having trouble"

#Cek status service zimbra
zimbra_service_status=$(su - zimbra -c 'zmcontrol status')

#Cek jika ada service yang berhenti dan tidak berjalan
zimbra_service_stopped=$(su - zimbra -c 'zmcontrol status' | grep -ic "stopped")
zimbra_service_not_running=$(su - zimbra -c 'zmcontrol status' | grep -ic "not running")

#Jika ada service yang berhenti atau tidak berjalan maka ...
if [ $zimbra_service_stopped -gt 0 ] || [ $zimbra_service_not_running -gt 0 ]
then

	#Kirimkan e-mail berisi status service zimbra (harus menginstall aplikasi sendemail, bukan sendmail)
	sendEmail -f "$from" -t "$target" -s "$smtp" -o tls="$tls" -xu "$from" -xp "$pass" -u "$subject" -m "$zimbra_service_status"
	
	#Matikan proses berdasarkan port yang digunakan, kemungkinan zimbra gagal dijalankan menggunakan port ini
	ZimbraSafePorts=( 25, 53, 110, 143, 389, 443, 465, 587, 636, 993, 995, 3310, 3443, 7025, 7026, 7047, 7071, 7072, 7073, 7110, 7143, 7171, 7306, 7780, 7993, 7995, 8080, 8443, 8465, 9071, 10024, 10025, 10026, 10027, 10028, 10029, 10030, 10031, 10032, 10663, 11211, 23232, 23233)
	for port in "${ZimbraSafePorts[@]}"
	do
		pid=$(lsof -i:$port -t); kill -TERM $pid || kill -KILL $pid
	done
	
	#Restart service zimbra
	su - zimbra -c 'zmcontrol restart'

fi
