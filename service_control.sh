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
	sendEmail -f "$from" -t "$target" -s "$smtp" -o tls='"$tls"' -xu "$from" -xp "$pass" -u "$subject" -m "$zimbra_service_status"
	
	#Stop service zimbra
	su - zimbra -c 'zmcontrol stop'
	
	#Restart OS
	reboot

fi
