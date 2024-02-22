#!/bin/bash
set -euo pipefail

sed -i "s|\$MAX_SIZE|"${MAX_SIZE:-10g}"|" /etc/nginx/nginx.conf
sed -i "s|MYUPSTREAM|"${UPSTREAM}"|g" /etc/nginx/nginx.conf
sed -i "s|\$GZIP|"${GZIP:-on}"|" /etc/nginx/nginx.conf
sed -i "s|\$ALLOWED_ORIGIN|"${ALLOWED_ORIGIN:-*}"|" /etc/nginx/nginx.conf
sed -i "s|\$PROXY_READ_TIMEOUT|"${PROXY_READ_TIMEOUT:-120s}"|" /etc/nginx/nginx.conf
sed -i "s|\$MAX_INACTIVE|"${MAX_INACTIVE:-60m}"|" /etc/nginx/nginx.conf

[[ -z "$PORT" ]] || sed -i "s|listen 80|listen "$PORT"|" /etc/nginx/nginx.conf

timeout 10 curl -6 https://www.google.com -o /dev/null && sed 's/ipv6=off//g' -i /etc/nginx/nginx.conf

if [[ "${PROXY_CACHE_VALID+x}" ]]; then
  PROXY_CACHE_VALID="proxy_cache_valid ${PROXY_CACHE_VALID};"
fi
sed -i "s|\$PROXY_CACHE_VALID|${PROXY_CACHE_VALID-}|" /etc/nginx/nginx.conf
nginx -t || nginx -T
exec "$@"
