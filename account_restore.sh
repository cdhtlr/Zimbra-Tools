#!/bin/bash
DOMAINS="domains.txt"
USERS="emails.txt"
USERDATA="userdata"
USERFILTER="userfilter"
DISTRIBUTIONLIST="distributionlist.txt"
DISTRIBUTIONLIST_MEMBERS="distributionlist_members"

############################ Mengembalikan (restore) semua domain ke server saat ini ############################
echo "======> 1/3. Mulai : Import daftar domain <======"
for i in $(cat $DOMAINS)
do
	/opt/zimbra/bin/zmprov cd "$i" zimbraAuthMech zimbra
	echo "$i -- domain imported"
done
echo "======> 1/3. Selesai : Import daftar domain <======"

################## Mengembalikan (restore) semua email beserta mailboxnya ke server saat ini ###################
echo "======> 2/3. Mulai : Import daftar email non-admin beserta mailboxnya <======"
for i in $(cat $USERS)
do
	cn=$(grep cn: $USERDATA/$i.txt | cut -d ":" -f2)
	givenName=$(grep givenName: $USERDATA/$i.txt | cut -d ":" -f2)
	displayName=$(grep displayName: $USERDATA/$i.txt | cut -d ":" -f2)
	zimbraAccountStatus=$(grep zimbraAccountStatus: $USERDATA/$i.txt | cut -d ":" -f2)
	zimbraFilePreviewMaxSize=$(grep zimbraFilePreviewMaxSize: $USERDATA/$i.txt | cut -d ":" -f2)
	zimbraFileUploadMaxSizePerFile=$(grep zimbraFileUploadMaxSizePerFile: $USERDATA/$i.txt | cut -d ":" -f2)
	zimbraFeatureFiltersEnabled=$(grep zimbraFeatureFiltersEnabled: $USERDATA/$i.txt | cut -d ":" -f2)
	zimbraFeatureSignaturesEnabled=$(grep zimbraFeatureSignaturesEnabled: $USERDATA/$i.txt | cut -d ":" -f2)
	zimbraFeatureExportFolderEnabled=$(grep zimbraFeatureExportFolderEnabled: $USERDATA/$i.txt | cut -d ":" -f2)
	zimbraFeatureImportFolderEnabled=$(grep zimbraFeatureImportFolderEnabled: $USERDATA/$i.txt | cut -d ":" -f2)
	zimbraFeatureImportExportFolderEnabled=$(grep zimbraFeatureImportExportFolderEnabled: $USERDATA/$i.txt | cut -d ":" -f2)
	zimbraMailForwardingAddress=$(grep zimbraMailForwardingAddress: $USERDATA/$i.txt | cut -d ":" -f2)
	zimbraFeatureMailForwardingEnabled=$(grep zimbraFeatureMailForwardingEnabled: $USERDATA/$i.txt | cut -d ":" -f2)
	zimbraMailQuota=$(grep zimbraMailQuota: $USERDATA/$i.txt | cut -d ":" -f2)
	zimbraMaxContactsPerPage=$(grep zimbraMaxContactsPerPage: $USERDATA/$i.txt | cut -d ":" -f2)
	zimbraMaxMailItemsPerPage=$(grep zimbraMaxMailItemsPerPage: $USERDATA/$i.txt | cut -d ":" -f2)
	zimbraPrefContactsPerPage=$(grep zimbraPrefContactsPerPage: $USERDATA/$i.txt | cut -d ":" -f2)
	zimbraPrefMailForwardingAddress=$(grep zimbraPrefMailForwardingAddress: $USERDATA/$i.txt | cut -d ":" -f2)
	zimbraPrefTimeZoneId=$(grep zimbraPrefInboxUnreadLifetime: $USERDATA/$i.txt | cut -d ":" -f2)
	userPassword=$(grep userPassword: $USERDATA/$i.txt | cut -d ":" -f2)
	tmpPass="CHANGEme"
	/opt/zimbra/bin/zmprov ca "$i" "$tmpPass" cn "$cn" givenName "$givenName" displayName "$displayName" zimbraAccountStatus "$zimbraAccountStatus" zimbraFilePreviewMaxSize "$zimbraFilePreviewMaxSize" zimbraFileUploadMaxSizePerFile "$zimbraFileUploadMaxSizePerFile" zimbraFeatureFiltersEnabled "$zimbraFeatureFiltersEnabled" zimbraFeatureSignaturesEnabled "$zimbraFeatureSignaturesEnabled" zimbraFeatureExportFolderEnabled "$zimbraFeatureExportFolderEnabled" zimbraFeatureImportFolderEnabled "$zimbraFeatureImportFolderEnabled" zimbraFeatureImportExportFolderEnabled "$zimbraFeatureImportExportFolderEnabled" zimbraMailForwardingAddress="$zimbraMailForwardingAddress" zimbraFeatureMailForwardingEnabled "$zimbraFeatureMailForwardingEnabled" zimbraFeatureMailForwardingInFiltersEnabled "$zimbraFeatureMailForwardingInFiltersEnabled" zimbraMailQuota "$zimbraMailQuota" zimbraMaxContactsPerPage "$zimbraMaxContactsPerPage" zimbraMaxMailItemsPerPage "$zimbraMaxMailItemsPerPage" zimbraPrefContactsPerPage "$zimbraPrefContactsPerPage" zimbraPrefMailForwardingAddress "$zimbraPrefMailForwardingAddress" zimbraPrefTimeZoneId "$zimbraPrefTimeZoneId" zimbraFeatureChangePasswordEnabled "FALSE" zimbraFeatureMailForwardingInFiltersEnabled "TRUE"
	/opt/zimbra/bin/zmprov ma "$i" userPassword "$userPassword"
	echo "$i -- user imported"
	/opt/zimbra/bin/zmmailbox -z -m "$i" postRestURL "//?fmt=zip&resolve=reset" "$USERDATA"/"$i".zip
	echo "$i -- data restored"
	/opt/zimbra/bin/zmprov ma "$i" zimbraMailSieveScript "'$(cat $USERFILTER/$i.txt)'"
	echo "$i -- filter restored"
done
echo "======> 2/3. Selesai : Import daftar email non-admin beserta mailboxnya <======"

##################### Mengembalikan (restore) daftar distribution list beserta membernya ######################
echo "======> 3/3. Mulai : Import daftar distributionlist <======"
for i in $(cat $DISTRIBUTIONLIST)
do
	/opt/zimbra/bin/zmprov cdl "$i"
	echo "$i -- distributionlist imported"
	for j in "grep -v '#' $DISTRIBUTIONLIST_MEMBERS/$i.txt |grep '@'"
	do
		/opt/zimbra/bin/zmprov adlm "$i" "$j"
		echo "$j member has been added to list $i"
	done
done
echo "======> 3/3. Selesai : Import daftar distributionlist <======"

################################### Selesai bro, tinggal cek bener atw kaga ###################################
echo "Selesai bro, tinggal cek bener atw kaga :)"
