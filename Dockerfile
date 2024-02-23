FROM nginx

RUN mkdir /cache \
 && chown nginx /cache
COPY nginx.conf /etc/nginx/nginx.conf
COPY entrypoint.sh /entrypoint.sh
COPY nginx.sh /nginx.sh

RUN RUN apt-get update && apt-get -y install unbound && apt-get clean all
RUN wget -S https://www.internic.net/domain/named.cache -O /etc/unbound/root.hints
ENTRYPOINT ["/entrypoint.sh"]
CMD ["sh", "/nginx.sh"]
