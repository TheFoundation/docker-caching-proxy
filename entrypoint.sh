#!/bin/bash
#set -euo pipefail
INTPORT=10000

sed -i "s|\$MAX_SIZE|"${MAX_SIZE:-10g}"|" /etc/nginx/nginx.conf
REALUPSTREAM=$(echo "$UPSTREAM"|sed 's~https://~~g;s~http://~~g'|sed 's/\/.\+//g')
sed -i "s|MYUPSTREAM|"${REALUPSTREAM}"|g" /etc/nginx/nginx.conf
sed -i "s|MYUPSTREAM|"${INTPORT}"|g" /etc/nginx/nginx.conf
socat TCP-LISTEN:${INTPORT},fork,reuseaddr,bind=127.0.0.1 OPENSSL-CONNECT:$MYUPSTREAM.443,verify=0 & 
sed -i "s|\$GZIP|"${GZIP:-on}"|" /etc/nginx/nginx.conf
sed -i "s|\$ALLOWED_ORIGIN|"${ALLOWED_ORIGIN:-*}"|" /etc/nginx/nginx.conf
sed -i "s|\$PROXY_READ_TIMEOUT|"${PROXY_READ_TIMEOUT:-120s}"|" /etc/nginx/nginx.conf
sed -i "s|\$MAX_INACTIVE|"${MAX_INACTIVE:-60m}"|" /etc/nginx/nginx.conf

echo "$UPSTREAM_PROTO"|grep -q ^$ && UPSTREAM_PROTO="https"
sed -i "s|UPSTREAM_PROTO|"${UPSTREAM_PROTO}"|" /etc/nginx/nginx.conf


echo "${MORE_UPSTREAMS}"|sed 's/|/\n/g'|while read addserv;do 
INTPORT=$(expr ${INTPORT} + 1)
REALSRV=$(echo "$addsrv"|sed 's~https://~~g;s~http://~~g'|sed 's/\/.\+//g')
sed -i 's|#more_backends|#more_backends\n     server '${REALUPSTREAM}":"$INTPORT";|g" /etc/nginx/nginx.conf
socat TCP-LISTEN:${INTPORT},fork,reuseaddr,bind=127.0.0.1 OPENSSL-CONNECT:$REALSRV.443,verify=0 & 

done
[[ -z "$PORT" ]] || sed -i "s|listen 80|listen "$PORT"|" /etc/nginx/nginx.conf

timeout 10 curl -6 https://www.google.com -o /dev/null && ( 
     sed 's/ipv6=off//g' -i /etc/nginx/nginx.conf
     sed 's~private-address: ::/0~#private-address: ::/0~g' /etc/unbound.conf
)

if [[ "${PROXY_CACHE_VALID+x}" ]]; then
  PROXY_CACHE_VALID="proxy_cache_valid ${PROXY_CACHE_VALID};"
fi
sed -i "s|\$PROXY_CACHE_VALID|${PROXY_CACHE_VALID-}|" /etc/nginx/nginx.conf
nginx -t || nginx -T
nginx -t || exit 1
unbound -dd -c /etc/unbound.conf &
sleep 1
exec "$@" 
