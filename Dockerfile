FROM ahmdrz/rp:latest
RUN apk add  --no-cache unbound wget bind-tools redis nginx nginx-mod-http-redis2
#FROM nginx
#RUN  apt-get update && apt-get -y install dnsutils socat unbound wget && apt-get clean all
RUN wget -S -c https://www.internic.net/domain/named.cache -O /etc/unbound/root.hints
#COPY --from=ahmdrz/rp:latest /usr/local/bin/rp /usr/bin/rp
WORKDIR /

RUN mkdir /cache \
 && chown nginx /cache
 RUN mkdir /redis \
 && chown redis /cache
COPY nginx.conf /etc/nginx/nginx.conf
COPY rp.yaml /rp.yaml

COPY entrypoint.sh /usr/bin/entrypoint.sh
COPY nginx.sh /nginx.sh
COPY redis.conf /etc/redis.conf

COPY unbound.conf /etc/unbound.conf
RUN ls /
ENTRYPOINT ["ash"]
CMD ["/usr/bin/entrypoint.sh"]
