#!/bin/bash

force=0
once=0

for arg in "$@" ; do
  case "$arg" in
    --force) force=1 ;;
    --once)  once=1  ;;
    *)       echo "Unknown option: $arg (supported: --force, --once)" >&2 ; exit 1 ;;
  esac
done

## init files
touch /conf/cloudflare.ini
touch /conf/email.ini
touch /conf/register.list

chmod 700 /conf/cloudflare.ini

## run forever (or once with --once)
while true ; do
  date
  certbot certificates

  for d in $(cat /conf/register.list | sed "s/,/ /g") ; do
    echo $d ;
    echo "Q" | openssl s_client -servername $d -connect ${d}:443 2>/dev/null | openssl x509 -noout -dates ;
  done

  while IFS= read -r line ; do
    echo $line
    set -x
    if [ "$force" -eq 1 ] ; then
      certbot certonly --force-renewal
    else
      certbot certonly
    fi \
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

  if [ "$once" -eq 1 ] ; then
    break
  fi

  ## Attempt to renew/create every 12h.
  set -x
  sleep 12h
  set +x

done
