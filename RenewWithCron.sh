#!/bin/bash

###----------------------------------------------------------------------------------------------------###
#Usage       :  /usr/bin/certbot renew --renew-hook 'bash RenewWithCron.sh'                                                                                             
#Description :  Permet d’automatiser le renouvellement de certificats Let’s Encrypt.                                                                               
#            :  A exécuter en root avec cron.                                                                                         
#Authors     :  daniel.massy@gmail.com, pouteau.aurelie14@gmail.com
#            :  yann.ndongui@gmail.com, killian.boulard@gmail.com                                                 
###----------------------------------------------------------------------------------------------------###

set -e

declare -r FullKeyDomaine="web.tpdaniel.fr.pem"
declare -r HaproxyCrtDir="/etc/haproxy/certs"
declare Rep=$(ls -d /etc/letsencrypt/live/*[!README])

for Dir in $Rep
do
  bash -c "cat $Dir/privkey.pem $Dir/fullchain.pem > ${HaproxyCrtDir}/${FullKeyDomaine}"
  if [ "${?}" == "0" ]
  then
    /usr/bin/logger -t HaproxyRenew "Mise à jour du fichier ${HaproxyCrtDir}/${FullKeyDomaine} réussi !"
  else
    /usr/bin/logger -t HaproxyRenew "Erreur de concaténation du certificat !"
    exit 0
  fi
done

/usr/bin/chmod -R go-rwx ${HaproxyCrtDir}

/etc/init.d/haproxy reload | /usr/bin/logger -t HaproxyRenew