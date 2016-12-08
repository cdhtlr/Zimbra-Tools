#!/bin/bash
######## Membuat directory kerja untuk backup, mengatur hak akses, dan berpindah user menjadi zimbra ########
echo "======> 1/10. Membuat directory untuk backup dan mengatur hak akses <======"
mkdir /backups/zmigrate
chown zimbra.zimbra /backups/zmigrate
su - zimbra

############################# Pindah ke folder kerja lalu export daftar domain ##############################
cd /backups/zmigrate
echo "======> 2/10. Mulai : Export daftar domain <======"
zmprov gad > domains.txt
cat domains.txt
echo "======> 2/10. Selesai : Export daftar domain <======"

############################## Export daftar semua email yang merupakan admin ###############################
echo "======> 3/10. Mulai : Export daftar admin <======"
zmprov gaaa > admins.txt
cat admins.txt
echo "======> 3/10. Selesai : Export daftar admin <======"

################################ Export daftar semua email yang bukan admin #################################
echo "======> 4/10. Mulai : Export daftar email non-admin <======"
zmprov -l gaa > emails.txt
cat emails.txt
echo "======> 4/10. Selesai : Export daftar email non-admin <======"

###################################### Export daftar distribution list ######################################
echo "======> 5/10. Mulai : Export daftar distribution list <======"
zmprov gadl > distributionlist.txt
cat distributionlist.txt
echo "======> 5/10. Selesai : Export daftar distribution list <======"

############################# Export semua member dari daftar distribution list #############################
echo "======> 6/10. Mulai : Export semua member dari daftar distribution list <======"
mkdir distributionlist_members
for i in 'cat distributionlist.txt'; do zmprov gdlm $i > distributionlist_members/$i.txt ;echo "$i"; done
echo "======> 6/10. Selesai : Export semua member dari daftar distribution list <======"

############################# Export password dari semua email yang bukan admin #############################
echo "======> 7/10. Mulai : Export semua password email non-admin <======"
mkdir userpass
for i in 'cat emails.txt'; do zmprov  -l ga $i userPassword | grep userPassword: | awk '{ print $2}' > userpass/$i.shadow; done
echo "======> 7/10. Selesai : Export semua password email non-admin <======"

############## Export user name, display name, dan given name dari semua email yang bukan admin #############
echo "======> 8/10. Mulai : Export user name, display name, dan given name dari semua email non-admin <======"
mkdir userdata
for i in 'cat emails.txt'; do zmprov ga $i  | grep -i Name: > userdata/$i.txt ; done
echo "======> 8/10. Selesai : Export user name, display name, dan given name dari semua email non-admin <======"

### Membuat backup berupa file arsip untuk masing-masing email yang bukan admin. Untuk nanti di-restore #####
############# Terdiri dari Mail, Contacts, Calendars, Briefcase, Tasks, Searches, Tags, Folders #############
########################################## Kecuali Junk dan Trash ###########################################
echo "======> 9/10. Mulai : Mencadangkan folder Mail, Contacts, Calendars, Briefcase, Tasks, Searches, Tags, dan Folders dari semua email non-admin <======"
for email in 'cat emails.txt'; do  zmmailbox -z -m $i getRestURL '/?fmt=tgz' > $i.tgz ;  echo $email ; done
echo "======> 9/10. Selesai : Mencadangkan folder Mail, Contacts, Calendars, Briefcase, Tasks, Searches, Tags, dan Folders dari semua email non-admin <======"

######################################### Export daftar email alias #########################################
echo "======> 10/10. Mulai : Export semua email alias <======"
mkdir -p alias/
for i in 'cat emails.txt'; do zmprov ga  $i | grep zimbraMailAlias |awk '{print $2}' > alias/$i.txt ;echo $i ;done
find alias/ -type f -empty | xargs -n1 rm -v 
echo "======> 10/10. Selesai : Export semua email alias <======"

######## Selesai bro, tinggal pindahin semua file hasil backup ke server tujuan (baru/tempat restore) pake rsync atau manual boleh #######
echo "Selesai bro, tinggal pindahin semua file hasil backup ke server tujuan (baru/tempat restore) pake rsync atau manual boleh"