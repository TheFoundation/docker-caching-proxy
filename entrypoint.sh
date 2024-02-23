#!/bin/bash
#set -euo pipefail

sed -i "s|\$MAX_SIZE|"${MAX_SIZE:-10g}"|" /etc/nginx/nginx.conf
REALUPSTREAM=$(echo "$UPSTREAM"|sed 's~https://~~g;s~http://~~g'|sed 's/\/.\+//g')
sed -i "s|MYUPSTREAM|"${REALUPSTREAM}"|g" /etc/nginx/nginx.conf
sed -i "s|\$GZIP|"${GZIP:-on}"|" /etc/nginx/nginx.conf
sed -i "s|\$ALLOWED_ORIGIN|"${ALLOWED_ORIGIN:-*}"|" /etc/nginx/nginx.conf
sed -i "s|\$PROXY_READ_TIMEOUT|"${PROXY_READ_TIMEOUT:-120s}"|" /etc/nginx/nginx.conf
sed -i "s|\$MAX_INACTIVE|"${MAX_INACTIVE:-60m}"|" /etc/nginx/nginx.conf

echo "$UPSTREAM_PROTO"|grep -q ^$ && UPSTREAM_PROTO="https"
sed -i "s|UPSTREAM_PROTO|"${UPSTREAM_PROTO}"|" /etc/nginx/nginx.conf


echo "$MORE_UPSTREAMS"|sed 's/|/\n/g'|while read addserv;do 
REALSRV=$(echo "$addsrv"|sed 's~https://~~g;s~http://~~g'|sed 's/\/.\+//g')
sed -i 's|#more_backends|#more_backends\n     server '${REALUPSTREAM}";|g" /etc/nginx/nginx.conf
done
[[ -z "$PORT" ]] || sed -i "s|listen 80|listen "$PORT"|" /etc/nginx/nginx.conf

timeout 10 curl -6 https://www.google.com -o /dev/null && sed 's/ipv6=off//g' -i /etc/nginx/nginx.conf

if [[ "${PROXY_CACHE_VALID+x}" ]]; then
  PROXY_CACHE_VALID="proxy_cache_valid ${PROXY_CACHE_VALID};"
fi
sed -i "s|\$PROXY_CACHE_VALID|${PROXY_CACHE_VALID-}|" /etc/nginx/nginx.conf
nginx -t || nginx -T

exec "$@" 
