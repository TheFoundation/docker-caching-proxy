FROM ghcr.io/thefoundation/rp:latest
#FROM ahmdrz/rp:latest
#FROM nginx
#RUN  apt-get update && apt-get -y install dnsutils socat unbound wget && apt-get clean all
RUN apk add unbound wget bind-tools redis git nginx nginx-mod-http-redis2

#ENV NGINX_VERSION 1.21.1
#ENV HTTP_REDIS_VERSION 0.3.9


#RUN GPG_KEYS="B0F4253373F8F6F510D42178520A9993A1C052F8" \
#	&& export GNUPGHOME=/root/.gpg \
#	&& found=''; \
#	for server in \
#		ha.pool.sks-keyservers.net \
#		hkp://keyserver.ubuntu.com:80 \
#		hkp://p80.pool.sks-keyservers.net:80 \
#		pgp.mit.edu \
#	; do \
#		echo "Fetching GPG key $GPG_KEYS from $server"; \
#		gpg --keyserver "$server" --keyserver-options timeout=10 --recv-keys "$GPG_KEYS" && found=yes && break; \
#	done && \
#	( test -z "$found" &&  echo >&2 "error: failed to fetch GPG key $GPG_KEYS" &&  exit 1 ) || true  
#
#
#RUN ash -c "mkdir -p /usr/src||true ;cd /usr/src/ ;git clone https://github.com/openresty/srcache-nginx-module.git /usr/src/srcache-nginx-module & git clone https://github.com/openresty/redis2-nginx-module.git;wait " && export GNUPGHOME=/root/.gpg && CONFIG="\
#		--prefix=/etc/nginx \
#		--sbin-path=/usr/sbin/nginx \
#		--modules-path=/usr/lib/nginx/modules \
#		--conf-path=/etc/nginx/nginx.conf \
#		--error-log-path=/var/log/nginx/error.log \
#		--http-log-path=/var/log/nginx/access.log \
#		--pid-path=/var/run/nginx.pid \
#		--lock-path=/var/run/nginx.lock \
#		--http-client-body-temp-path=/var/cache/nginx/client_temp \
#		--http-proxy-temp-path=/var/cache/nginx/proxy_temp \
#		--http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
#		--http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
#		--http-scgi-temp-path=/var/cache/nginx/scgi_temp \
#		--user=nginx \
#		--group=nginx \
#		--with-http_ssl_module \
#		--with-http_realip_module \
#		--with-http_addition_module \
#		--with-http_sub_module \
#		--with-http_dav_module \
#		--with-http_flv_module \
#		--with-http_mp4_module \
#		--with-http_gunzip_module \
#		--with-http_gzip_static_module \
#		--with-http_random_index_module \
#		--with-http_secure_link_module \
#		--with-http_stub_status_module \
#		--with-http_auth_request_module \
#		--with-http_xslt_module=dynamic \
#		--with-http_image_filter_module=dynamic \
#		--with-http_geoip_module=dynamic \
#		--with-threads \
#		--with-stream \
#		--with-stream_ssl_module \
#		--with-stream_ssl_preread_module \
#		--with-stream_realip_module \
#		--with-stream_geoip_module=dynamic \
#		--with-http_slice_module \
#		--with-mail \
#		--with-mail_ssl_module \
#		--with-compat \
#		--with-file-aio \
#		--with-http_v2_module \
#		--add-module=/usr/src/ngx_http_redis-$HTTP_REDIS_VERSION --add-module=/usr/src/srcache-nginx-module --add-module=/usr/src/redis2-nginx-module" \
#	&& addgroup -S nginx \
#	&& adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx \
#	&& apk add --no-cache --virtual .build-deps \
#		gcc \
#		libc-dev \
#		make \
#		openssl-dev \
#		pcre-dev \
#		zlib-dev \
#		linux-headers \
#		curl \
#		gnupg \
#		libxslt-dev \
#		gd-dev \
#		geoip-dev \
#	&& curl -fSL http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz -o nginx.tar.gz \
#	&& curl -fSL http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz.asc  -o nginx.tar.gz.asc \
#	&& curl -fSL https://people.freebsd.org/~osa/ngx_http_redis-$HTTP_REDIS_VERSION.tar.gz -o ngx_http_redis.tar.gz && \
#	gpg --batch --verify nginx.tar.gz.asc nginx.tar.gz || true \
#	&& rm -r nginx.tar.gz.asc \
#	&& mkdir -p /usr/src \
#	&& tar -zxC /usr/src -f nginx.tar.gz \
#	&& rm nginx.tar.gz \
#	&& tar -zxC /usr/src -f ngx_http_redis.tar.gz \
#	&& rm ngx_http_redis.tar.gz \
#	&& cd /usr/src/nginx-$NGINX_VERSION \
#	&& ./configure $CONFIG --with-debug \
#	&& make -j$(($(getconf _NPROCESSORS_ONLN)*2-2)) \
#	&& mv objs/nginx objs/nginx-debug \
#	&& mv objs/ngx_http_xslt_filter_module.so objs/ngx_http_xslt_filter_module-debug.so \
#	&& mv objs/ngx_http_image_filter_module.so objs/ngx_http_image_filter_module-debug.so \
#	&& mv objs/ngx_http_geoip_module.so objs/ngx_http_geoip_module-debug.so \
#	&& mv objs/ngx_stream_geoip_module.so objs/ngx_stream_geoip_module-debug.so \
#	&& ./configure $CONFIG \
#	&& make -j$(getconf _NPROCESSORS_ONLN) \
#	&& make install \
#	&& rm -rf /etc/nginx/html/ \
#	&& mkdir /etc/nginx/conf.d/ \
#	&& mkdir -p /usr/share/nginx/html/ \
#	&& install -m644 html/index.html /usr/share/nginx/html/ \
#	&& install -m644 html/50x.html /usr/share/nginx/html/ \
#	&& install -m755 objs/nginx-debug /usr/sbin/nginx-debug \
#	&& install -m755 objs/ngx_http_xslt_filter_module-debug.so /usr/lib/nginx/modules/ngx_http_xslt_filter_module-debug.so \
#	&& install -m755 objs/ngx_http_image_filter_module-debug.so /usr/lib/nginx/modules/ngx_http_image_filter_module-debug.so \
#	&& install -m755 objs/ngx_http_geoip_module-debug.so /usr/lib/nginx/modules/ngx_http_geoip_module-debug.so \
#	&& install -m755 objs/ngx_stream_geoip_module-debug.so /usr/lib/nginx/modules/ngx_stream_geoip_module-debug.so \
#	&& ln -s ../../usr/lib/nginx/modules /etc/nginx/modules \
#	&& strip /usr/sbin/nginx* \
#	&& strip /usr/lib/nginx/modules/*.so \
#	&& rm -rf /usr/src/nginx-$NGINX_VERSION \
#	&& rm -rf /usr/src/ngx_http_redis-$HTTP_REDIS_VERSION \
#	\
#	# Bring in gettext so we can get `envsubst`, then throw
#	# the rest away. To do this, we need to install `gettext`
#	# then move `envsubst` out of the way so `gettext` can
#	# be deleted completely, then move `envsubst` back.
#	&& apk add --no-cache --virtual .gettext gettext \
#	&& mv /usr/bin/envsubst /tmp/ \
#	\
#	&& runDeps="$( \
#		scanelf --needed --nobanner /usr/sbin/nginx /usr/lib/nginx/modules/*.so /tmp/envsubst \
#			| awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
#			| sort -u \
#			| xargs -r apk info --installed \
#			| sort -u \
#	)" \
#	&& apk add --no-cache --virtual .nginx-rundeps $runDeps \
#	&& apk del .build-deps \
#	&& apk del .gettext \
#	&& mv /tmp/envsubst /usr/local/bin/ \
#	\
#	# forward request and error logs to docker log collector
#	&& ln -sf /dev/stdout /var/log/nginx/access.log \
#	&& ln -sf /dev/stderr /var/log/nginx/error.log
#
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
COPY --from=ghcr.io/thefoundation/cache-proxy:latest /usr/local/bin/cache-proxy /usr/bin/cache-proxy
#COPY --from=pierredavidbelanger/cache-proxy:latest /usr/local/bin/cache-proxy /usr/bin/cache-proxy
RUN ls /
ENTRYPOINT ["ash"]
CMD ["/usr/bin/entrypoint.sh"]
