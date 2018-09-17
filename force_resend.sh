#!/bin/bash

while true
do
	for EMAIL in $(/opt/zimbra/common/sbin/postqueue -p | grep -v ^- | grep -v '(' | cut -d ' ' -f11 | grep -e [[:alnum:]] | sort -u)
	do
		for ID in $(/opt/zimbra/common/sbin/postqueue -p | grep -v ^- | grep -v '(' | grep '$EMAIL' | cut -d ' ' -f1 | grep -e [[:alnum:]] | grep -v '[*!]$' | grep -m1 '')
		do
			/opt/zimbra/common/sbin/postqueue -i $ID
			sleep 15
		done
	done
done
