#!/bin/bash

## init files 
touch /conf/cloudflare.ini
touch /conf/email.ini
touch /conf/register.list

chmod 700 /conf/cloudflare.ini

## run once
  date
  certbot certificates
  
  for d in $(cat /conf/register.list | sed "s/,/ /g") ; do 
    echo $d ;
    echo "Q" | openssl s_client -servername $d -connect ${d}:443 2>/dev/null | openssl x509 -noout -dates ;
  done

  while IFS= read -r line ; do  
    echo $line
    set -x
    certbot certonly --force-renewal \
      --non-interactive \
      --agree-tos \
      --email $(cat /conf/email.ini) \
      --dns-cloudflare \
      --dns-cloudflare-credentials /conf/cloudflare.ini \
      --dns-cloudflare-propagation-seconds 630 \
      --expand \
      -d "$line" 
    set +x
  done < "/conf/register.list"
  
  ## Post command to prepare pem for HAProxy.
  ./combineFullPrivKeys.sh

  set -x
