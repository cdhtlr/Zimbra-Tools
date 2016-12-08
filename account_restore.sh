#!/bin/bash
su - zimbra
########################## Mengembalikan (restore) semua domain ke server saat ini ##########################
echo "======> 1/6. Mulai : Import semua domain <======"
for i in 'domains.txt'; do  zmprov cd $i zimbraAuthMech zimbra ;echo $i ;done
echo "======> 1/6. Selesai : Import semua domain <======"

########################## Mengembalikan (restore) semua email ke server saat ini ##########################
echo "======> 2/6. Mulai : Import email dan password <======"
USERPASS="userpass"
USERDDATA="userdata"
USERS="emails.txt"
for i in 'cat $USERS'
do
givenName=$(grep givenName: $USERDDATA/$i.txt | cut -d ":" -f2)
displayName=$(grep displayName: $USERDDATA/$i.txt | cut -d ":" -f2)
shadowpass=$(cat $USERPASS/$i.shadow)
tmpPass="CHANGEme"
zmprov ca $i CHANGEme cn "$givenName" displayName "$displayName" givenName "$givenName" 
zmprov ma $i userPassword "$shadowpass"
done
echo "======> 2/6. Selesai : Import email dan password <======"

### Mengembalikan (restore) semua folder Mail, Contacts, Calendars, Briefcase, Tasks, Searches, Tags, dan Folders ###
echo "======> 3/6. Mulai : Import daftar folder <======"
for i in 'emails.txt'; do zmmailbox -z -m $i postRestURL "/?fmt=tgz&resolve=skip" $i.tgz ;  ; echo "$i -- finished "; done
echo "======> 3/6. Selesai : Import daftar folder <======"

############################# Mengembalikan (restore) daftar distribution list ##############################
echo "======> 4/6. Mulai : Import daftar distributionlist <======"
for i in 'cat distributionlist.txt'; do zmprov cdl $i ; echo "$i -- done " ; done
echo "======> 4/6. Selesai : Import daftar distributionlist <======"

####################### Mengembalikan (restore) daftar email dari distribution list #########################
echo "======> 5/6. Mulai : Import daftar email dari distribution list <======"
for i in 'cat distributionlist.txt'
do
	for j in "grep -v '#' distributionlist_members/$i.txt |grep '@'" 
	do
	zmprov adlm $i $j
	echo " $j member has been added to list $i"
	done

done
echo "======> 5/6. Selesai : Import daftar email dari distribution list <======"

######################################### Import daftar email alias #########################################
echo "======> 6/6. Mulai : Import semua email alias <======"
for i in 'cat emails.txt'
do
	if [ -f "alias/$i.txt" ]; then
	for j in "grep '@' alias/$i.txt"
	do
	zmprov aaa $i $j
	echo "$i HAS ALIAS $j --- Restored"
	done
	fi
doneecho "======> 6/6. Selesai : Import semua email alias <======"

################################## Selesai bro, tinggal cek bener atw kaga ##################################
echo "Selesai bro, tinggal cek bener atw kaga"