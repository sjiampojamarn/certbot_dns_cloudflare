FROM certbot/dns-cloudflare

RUN apk add --no-cache bash openssl \
  && rm -rf /var/cache/apk/*

WOKRDIR /certbot_dns_cloudflare

COPY ./*.sh ./
RUN chmod +x ./*.sh

ENTRYPOINT ["./register.sh"]
