#!/bin/bash
set -e

declare -r FullKeyDomaine="web.tpdaniel.fr.pem"
declare -r HaproxyCrtDir="/etc/haproxy/certs"
declare Rep=$(ls -d /etc/letsencrypt/live/*[!README])

/usr/bin/certbot -q renew --force-renewal | /usr/bin/logger -t HaproxyRenew

for Dir in $Rep
do
  bash -c "cat $Dir/privkey.pem $Dir/fullchain.pem > ${HaproxyCrtDir}/${FullKeyDomaine}"
done

/usr/bin/chmod -R go-rwx ${HaproxyCrtDir}

/etc/init.d/haproxy reload | /usr/bin/logger -t HaproxyRenew