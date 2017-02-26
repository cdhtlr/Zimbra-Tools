#!/bin/bash
clear
USERS="emails.txt"
/opt/zimbra/bin/zmprov -l gaa > "$USERS"

for i in $(cat $USERS)
do
	j=$(echo $i) | cut -d "." -f1
	
	if [ $j == "admin" ] || [ $j == "wiki" ] || [ $j == "galsync" ] || [ $j == "ham" ] || [ $j == "spam" ]
		then echo "Skipping system account, $i"
	else
		echo "Modifying $i password..."
		/opt/zimbra/bin/zmprov sp "$i" ThisIsYourNewPasswordChangeIt
		/opt/zimbra/bin/zmprov ma "$i" zimbraPasswordMustChange TRUE
	fi
done
rm -rf "$USERS"
echo "Modifying password for all user has been finished successfuly"
