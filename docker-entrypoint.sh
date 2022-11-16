#!/bin/sh
set -e

if [ ! -f /root/sd/pywork/dr_py/app.py ] 
then
	git clone --depth 1 -q ${REPO_URL} .
	rm -rf .git* base/rules.db
	echo "App Initialized from zero"
	echo "Version $(cat js/version.txt)"
else
	mv base/rules.db /tmp
	ls -A1 | xargs rm -rf
	git clone --depth 1 -q ${REPO_URL} .
	rm -rf .git*
	mv -f /tmp/rules.db base/
	echo "App Updated"
	echo "Version $(cat js/version.txt)"
fi

if [ ! -f /etc/supervisord.conf ]; then
	cp /etc/supervisord.init /etc/supervisord.conf
	echo "Supervisord Initialized"
fi

exec "$@"
