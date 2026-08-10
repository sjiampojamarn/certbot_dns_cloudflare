FROM certbot/dns-cloudflare

RUN apk add --no-cache bash openssl \
  && rm -rf /var/cache/apk/*

WORKDIR /certbot_dns_cloudflare

COPY ./*.sh ./
RUN chmod +x ./*.sh

ENTRYPOINT ["./register.sh"]
