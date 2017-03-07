#!/bin/bash
DOMAINS="domains.txt"
USERS="emails.txt"
USERDATA="userdata"
USERALIAS="useralias"
USERFILTER="userfilter"
USERFORWARD="userforward"
USERPREFEREDFORWARD="userpreferedforward"
DISTRIBUTIONLIST="distributionlist.txt"
DISTRIBUTIONLIST_MEMBERS="distributionlist_members"

###################################### Export daftar domain #######################################
echo "======> 1/3. Mulai : Export daftar domain <======"
/opt/zimbra/bin/zmprov gad > "$DOMAINS"
cat "$DOMAINS"
echo "======> 1/3. Selesai : Export daftar domain <======"

############################# Export daftar semua email dan seisinya ##############################
echo "======> 2/3. Mulai : Export daftar email dan seisinya <======"
/opt/zimbra/bin/zmprov -l gaa > "$USERS"
cat "$USERS"
mkdir "$USERDATA"
mkdir "$USERALIAS"
mkdir "$USERFILTER"
mkdir "$USERFORWARD"
mkdir "$USERPREFEREDFORWARD"
for i in $(cat $USERS)
do
	/opt/zimbra/bin/zmprov -l ga "$i" > "$USERDATA"/"$i".txt
	echo "$i -- email exported"
	
	/opt/zimbra/bin/zmprov ga "$i" zimbraMailAlias > "$USERALIAS"/"$i".txt
	sed -i -e "1d" "$USERALIAS"/"$i".txt
	sed -i -e "s/zimbraMailAlias: //g" "$USERALIAS"/"$i".txt
	sed -i -e "s/^\t*$//g; s/^ *//; s/ *$//; /^$/d" "$USERALIAS"/"$i".txt
	if [[ $(find $USERALIAS"/"$i".txt" -type f -size +0c 2>/dev/null) ]]; then
		echo "$i -- alias exported"
	fi

	/opt/zimbra/bin/zmprov ga "$i" zimbraMailSieveScript > "$USERFILTER"/"$i".txt
	sed -i -e "1d" "$USERFILTER"/"$i".txt
	sed -i -e "s/zimbraMailSieveScript: //g" "$USERFILTER"/"$i".txt
	sed -i -e "s/^\t*$//g; s/^ *//; s/ *$//; /^$/d" "$USERFILTER"/"$i".txt
	if [[ $(find $USERFILTER"/"$i".txt" -type f -size +0c 2>/dev/null) ]]; then
		echo "$i -- filter exported"
	fi

	/opt/zimbra/bin/zmprov ga "$i" zimbraMailForwardingAddress > "$USERFORWARD"/"$i".txt
	sed -i -e "1d" "$USERFORWARD"/"$i".txt
	sed -i -e "s/zimbraMailForwardingAddress: //g" "$USERFORWARD"/"$i".txt
	sed -i -e "s/^\t*$//g; s/^ *//; s/ *$//; /^$/d" "$USERFORWARD"/"$i".txt
	if [[ $(find $USERFORWARD"/"$i".txt" -type f -size +0c 2>/dev/null) ]]; then
		echo "$i -- forwardlist exported"
	fi

	/opt/zimbra/bin/zmprov ga "$i" zimbraPrefMailForwardingAddress > "$USERPREFEREDFORWARD"/"$i".txt
	sed -i -e "1d" "$USERPREFEREDFORWARD"/"$i".txt
	sed -i -e "s/zimbraPrefMailForwardingAddress: //g" "$USERPREFEREDFORWARD"/"$i".txt
	sed -i -e "s/^\t*$//g; s/^ *//; s/ *$//; /^$/d" "$USERPREFEREDFORWARD"/"$i".txt
	if [[ $(find $USERPREFEREDFORWARD"/"$i".txt" -type f -size +0c 2>/dev/null) ]]; then
		echo "$i -- prefered forwardlist exported"
	fi

	/opt/zimbra/bin/zmmailbox -z -m "$i" getRestURL '//?fmt=zip' > "$USERDATA"/"$i".zip
	if [[ $(find $USERDATA"/"$i".zip" -type f -size +1c 2>/dev/null) ]]; then
		echo "$i -- data exported"
	fi
done
find "$USERALIAS"/ -type f -empty | xargs -n1 rm -v
find "$USERFILTER"/ -type f -empty | xargs -n1 rm -v
find "$USERFORWARD"/ -type f -empty | xargs -n1 rm -v
find "$USERPREFEREDFORWARD"/ -type f -empty | xargs -n1 rm -v
echo "======> 2/3. Selesai : Export daftar email dan seisinya <======"

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
