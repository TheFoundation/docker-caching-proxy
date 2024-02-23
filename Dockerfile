FROM ahmdrz/rp:latest
RUN apk add --no-cache unbound wget bind-tools
#FROM nginx
#RUN  apt-get update && apt-get -y install dnsutils socat unbound wget && apt-get clean all
RUN wget -S -c https://www.internic.net/domain/named.cache -O /etc/unbound/root.hints
COPY --from=ahmdrz/rp:latest /usr/local/bin/rp /usr/bin/rp
RUN mkdir /cache \
 && chown nginx /cache
COPY nginx.conf /etc/nginx/nginx.conf
COPY rp.yaml /rp.yaml

COPY entrypoint.sh /entrypoint.sh
COPY nginx.sh /nginx.sh
COPY unbound.conf /etc/unbound.conf

ENTRYPOINT ["/entrypoint.sh"]
CMD ["sh", "/nginx.sh"]
