#!/bin/bash

###----------------------------------------------------------------------------------------------------###
#Usage       :  30 19 20 */2 * root /usr/bin/bash /opt/certbot/LetsencryptRenew.sh                                                                                          
#Description :  Permet d’automatiser le renouvellement de certificats Let’s Encrypt.                                                                               
#            :  A exécuter en root avec cron.                                                                                         
#Authors     :  daniel.massy@gmail.com, pouteau.aurelie14@gmail.com
#            :  yann.ndongui@gmail.com, killian.boulard@gmail.com                                                 
###----------------------------------------------------------------------------------------------------###

# Exit si erreur
set -e

# Variables
declare -r FullKeyDomaine="web.tpdaniel.fr.pem"
declare -r HaproxyCrtDir="/etc/haproxy/certs"
declare Rep="$(ls -d /etc/letsencrypt/live/*[!README])"

/usr/bin/certbot -q renew --force-renewal | /usr/bin/logger -t HaproxyRenew

# concaténation
for Dir in "${Rep}"
do
  bash -c "cat ${Dir}/privkey.pem ${Dir}/fullchain.pem > ${HaproxyCrtDir}/${FullKeyDomaine}"
  if [ "${?}" == "0" ]
  then
    # Logger permet de créer des logs sur /var/log/syslog
    /usr/bin/logger -t HaproxyRenew "Mise à jour du fichier ${HaproxyCrtDir}/${FullKeyDomaine} réussi !"
  else
    /usr/bin/logger -t HaproxyRenew "Erreur de concaténation du certificat !"
    exit 0
  fi
done

# Protéction des certificats
/usr/bin/chmod -R go-rwx ${HaproxyCrtDir}

# Recharger la configuration de HAproxy
/etc/init.d/haproxy reload | /usr/bin/logger -t HaproxyRenew
