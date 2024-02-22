FROM nginx

RUN mkdir /cache \
 && chown nginx /cache
COPY nginx.conf /etc/nginx/nginx.conf
COPY entrypoint.sh /entrypoint.sh
COPY nginx.sh /nginx.sh


ENTRYPOINT ["/entrypoint.sh"]
CMD ["sh", "/nginx.sh"]
