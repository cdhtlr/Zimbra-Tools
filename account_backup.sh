#!/bin/bash
DOMAINS="domains.txt"
USERS="emails.txt"
USERDATA="userdata"
USERFILTER="userfilter"
DISTRIBUTIONLIST="distributionlist.txt"
DISTRIBUTIONLIST_MEMBERS="distributionlist_members"

###################################### Export daftar domain #######################################
echo "======> 1/3. Mulai : Export daftar domain <======"
/opt/zimbra/bin/zmprov gad > "$DOMAINS"
cat "$DOMAINS"
echo "======> 1/3. Selesai : Export daftar domain <======"

#################### Export daftar semua email beserta mailbox dan filter rule ####################
echo "======> 2/3. Mulai : Export daftar email beserta mailbox dan filter rule <======"
/opt/zimbra/bin/zmprov -l gaa > "$USERS"
cat "$USERS"
mkdir "$USERDATA"
mkdir "$USERFILTER"
for i in $(cat $USERS)
do
    /opt/zimbra/bin/zmprov -l ga "$i" > "$USERDATA"/"$i".txt
    echo "$i -- email exported"
    /opt/zimbra/bin/zmmailbox -z -m "$i" getRestURL '//?fmt=zip' > "$USERDATA"/"$i".zip
    echo "$i -- data exported"
    /opt/zimbra/bin/zmprov ga "$i" zimbraMailSieveScript > "$USERFILTER"/"$i".txt
    sed -i -e "1d" "$USERFILTER"/"$i".txt
    sed 's/zimbraMailSieveScript: //g' "$USERFILTER"/"$i".txt > "$USERFILTER"/"$i".txt
    echo "$i -- filter exported"
done 
echo "======> 2/3. Selesai : Export daftar email beserta mailbox dan filter rule <======"

######################## Export daftar distribution list beserta membernya ########################
echo "======> 3/3. Mulai : Export daftar distribution list beserta membernya <======"
/opt/zimbra/bin/zmprov gadl > "$DISTRIBUTIONLIST"
cat "$DISTRIBUTIONLIST"
mkdir "$DISTRIBUTIONLIST_MEMBERS"
for i in $(cat $DISTRIBUTIONLIST)
do
    /opt/zimbra/bin/zmprov gdlm "$i" > "$DISTRIBUTIONLIST_MEMBERS"/"$i".txt
    echo "$i -- distributionlist_members exported"
done
echo "======> 3/3. Selesai : Export daftar distribution list beserta membernya <======"

############################################ Selesai ##############################################
echo "Selesai bro, tinggal pindah secara manual atau pakai rsync :)"
echo "JANGAN LUPA HAPUS USER ADMIN, SPAM, HAM, dll yg ga penting :p"
