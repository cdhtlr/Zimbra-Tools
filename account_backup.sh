#!/bin/bash
DOMAINS="domains.txt"
ADMINS="admins.txt"
USERS="emails.txt"
DISTRIBUTIONLIST="distributionlist.txt"
USERPASS="userpass"
USERDATA="userdata"
############################# Export daftar domain ##############################
echo "======> 1/9. Mulai : Export daftar domain <======"
/opt/zimbra/bin/zmprov gad > "$DOMAINS"
cat "$DOMAINS"
echo "======> 1/9. Selesai : Export daftar domain <======"

############################## Export daftar semua email yang merupakan admin ###############################
echo "======> 2/9. Mulai : Export daftar admin <======"
/opt/zimbra/bin/zmprov gaaa > "$ADMINS"
cat "$ADMINS"
echo "======> 2/9. Selesai : Export daftar admin <======"

################################ Export daftar semua email yang bukan admin #################################
echo "======> 3/9. Mulai : Export daftar email non-admin <======"
/opt/zimbra/bin/zmprov -l gaa > "$USERS"
cat "$USERS"
echo "======> 3/9. Selesai : Export daftar email non-admin <======"

###################################### Export daftar distribution list ######################################
echo "======> 4/9. Mulai : Export daftar distribution list <======"
/opt/zimbra/bin/zmprov gadl > "$DISTRIBUTIONLIST"
cat "$DISTRIBUTIONLIST"
echo "======> 4/9. Selesai : Export daftar distribution list <======"

############################# Export semua member dari daftar distribution list #############################
echo "======> 5/9. Mulai : Export semua member dari daftar distribution list <======"
mkdir distributionlist_members
for i in $(cat $DISTRIBUTIONLIST); do /opt/zimbra/bin/zmprov gdlm "$i" > distributionlist_members/"$i".txt; echo "$i -- finished"; done
echo "======> 5/9. Selesai : Export semua member dari daftar distribution list <======"

############################# Export password dari semua email yang bukan admin #############################
echo "======> 6/9. Mulai : Export semua password email non-admin <======"
mkdir "$USERPASS"
for i in $(cat $USERS); do /opt/zimbra/bin/zmprov -l ga "$i" userPassword | grep userPassword: | awk '{ print $2}' > "$USERPASS"/"$i".shadow; echo "$i -- finished"; done
echo "======> 6/9. Selesai : Export semua password email non-admin <======"

############## Export user name, display name, dan given name dari semua email yang bukan admin #############
echo "======> 7/9. Mulai : Export user name, display name, dan given name dari semua email non-admin <======"
mkdir "$USERDATA"
for i in $(cat $USERS); do /opt/zimbra/bin/zmprov ga "$i" | grep -i Name: > "$USERDATA"/"$i".txt; echo "$i -- finished"; done
echo "======> 7/9. Selesai : Export user name, display name, dan given name dari semua email non-admin <======"

### Membuat backup berupa file arsip untuk masing-masing email yang bukan admin. Untuk nanti di-restore #####
############# Terdiri dari Mail, Contacts, Calendars, Briefcase, Tasks, Searches, Tags, Folders #############
########################################## Kecuali Junk dan Trash ###########################################
echo "======> 8/9. Mulai : Mencadangkan folder Mail, Contacts, Calendars, Briefcase, Tasks, Searches, Tags, dan Folders dari semua email non-admin <======"
for email in $(cat $USERS); do /opt/zimbra/bin/zmmailbox -z -m "$i" getRestURL '/?fmt=tgz' > "$i".tgz; echo "$email -- finished"; done
echo "======> 8/9. Selesai : Mencadangkan folder Mail, Contacts, Calendars, Briefcase, Tasks, Searches, Tags, dan Folders dari semua email non-admin <======"

######################################### Export daftar email alias #########################################
echo "======> 9/9. Mulai : Export semua email alias <======"
mkdir -p alias/
for i in $(cat $USERS); do /opt/zimbra/bin/zmprov ga "$i" | grep zimbraMailAlias |awk '{print $2}' > alias/"$i".txt; echo "$i -- finished"; done
find alias/ -type f -empty | xargs -n1 rm -v 
echo "======> 9/9. Selesai : Export semua email alias <======"

######## Selesai bro, tinggal pindahin semua file hasil backup ke server tujuan (baru/tempat restore) pake rsync atau manual boleh #######
echo "Selesai bro, tinggal pindahin semua file hasil backup ke server tujuan (baru/tempat restore) pake rsync atau manual boleh"
