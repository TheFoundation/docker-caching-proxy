#!/bin/bash
#set -euo pipefail
INTPORT=65533
echo "${UPSTREAM_PROTO}"|grep -q ^$ && UPSTREAM_PROTO="https"

while (true);do 
  redis-server /etc/redis.conf ;sleep 3
done &

cat /rp.yaml |tee /rp2.yaml >> /rp1.yaml
sed 's/65533/65534/g' -i /rp2.yaml
(mkdir -p  /var/run/redis/ ;chmod ugo+rwx  /var/run/redis/ ) &

sed -i "s|\$MAX_SIZE|"${MAX_SIZE:-10g}"|" /etc/nginx/nginx.conf
REALUPSTREAM=$(echo "${UPSTREAM}"|sed 's~https://~~g;s~http://~~g'|sed 's/\/.\+//g')
#sed -i "s|MYUPSTREAM|"${REALUPSTREAM}"|g" /etc/nginx/nginx.conf
sed -i "s|MYUPSTREAM|127.0.0.1|g" /etc/nginx/nginx.conf
sed -i 's~proxy_redirect default;~proxy_redirect default;\nproxy_redirect http://127.0.0.1:'${INTPORT}'/  $scheme$http_host/;\nproxy_redirect '${UPSTREAM_PROTO}'://'${REALUPSTREAM}'/  $scheme$http_host/;~g' /etc/nginx/nginx.conf
sed -i "s|MYPORT|"${INTPORT}"|g" /etc/nginx/nginx.conf
echo '- address: '${UPSTREAM_PROTO}"://"${REALUPSTREAM}'
  weight: 2'|tee -a  /rp2.yaml /rp1.yaml 
#socat "TCP-LISTEN:${INTPORT},fork,reuseaddr,bind=127.0.0.1" "OPENSSL-CONNECT:${REALUPSTREAM}:443,verify=0" & 
#sed 's/#morezones/#morezones\n         private-domain: "'${REALUPSTREAM}'"\n         local-data: "'${REALUPSTREAM}'. A 127.0.0.1"/g' -i /etc/unbound.conf

sed -i "s|\$GZIP|"${GZIP:-on}"|" /etc/nginx/nginx.conf
sed -i "s|\$ALLOWED_ORIGIN|"${ALLOWED_ORIGIN:-*}"|" /etc/nginx/nginx.conf
sed -i "s|\$PROXY_READ_TIMEOUT|"${PROXY_READ_TIMEOUT:-120s}"|" /etc/nginx/nginx.conf
sed -i "s|\$MAX_INACTIVE|"${MAX_INACTIVE:-60m}"|" /etc/nginx/nginx.conf


sed -i "s|UPSTREAM_PROTO|"${UPSTREAM_PROTO}"|" /etc/nginx/nginx.conf


INTPORT=$(expr ${INTPORT} + 1)
sed -i 's|#more_backends|#more_backends\n     server 127.0.0.1:'${INTPORT}"  max_fails=2 fail_timeout=5s;|g" /etc/nginx/nginx.conf
sed -i 's~proxy_redirect default;~proxy_redirect default;\nproxy_redirect http://127.0.0.1:'${INTPORT}'/  $scheme$http_host/;~g' /etc/nginx/nginx.conf

echo "${MORE_UPSTREAMS}"|sed 's/|/\n/g'|while read addsrv;do 
    INTPORT=$(expr ${INTPORT} + 1)
    REALSRV=$(echo "${addsrv}"|sed 's~https://~~g;s~http://~~g'|sed 's/\/.\+//g')
    # sed -i 's|#more_backends|#more_backends\n     server '${REALSRV}':'${INTPORT}"  max_fails=2 fail_timeout=5s;|g" /etc/nginx/nginx.conf
    #sed 's/#morezones/#morezones\n         private-domain: "'${REALSRV}'"\n         local-zone: "'${REALSRV}'." redirect\n         local-data: "'${REALSRV}'. A 127.0.0.1"/g' -i /etc/unbound.conf
    #socat "TCP-LISTEN:${INTPORT},fork,reuseaddr,bind=127.0.0.1" "OPENSSL-CONNECT:${REALSRV}:443,verify=0" & 
   sed -i 's~proxy_redirect default;~proxy_redirect default;\nproxy_redirect '${UPSTREAM_PROTO}'://'${REALSRV}'/  $scheme$http_host/;~g' /etc/nginx/nginx.conf

    echo '- address: '${UPSTREAM_PROTO}"://"${REALSRV}'
  weight: 2'|tee -a  /rp2.yaml /rp1.yaml 
done
#[[ -z "$PORT" ]] || sed -i "s|listen 80|listen "$PORT"|" /etc/nginx/nginx.conf

NGXPORT=8000
sed -i "s|listen 80|listen "$NGXPORT"|" /etc/nginx/nginx.conf

timeout 10 curl -6 https://www.google.com -o /dev/null && ( 
     sed 's/ipv6=off//g' -i /etc/nginx/nginx.conf
     sed 's~private-address: ::/0~#private-address: ::/0~g' /etc/unbound.conf
)

if [[ "${PROXY_CACHE_VALID+x}" ]]; then
  PROXY_CACHE_VALID="proxy_cache_valid ${PROXY_CACHE_VALID};"
fi
cat /etc/unbound.conf |nl
sed -i "s|\$PROXY_CACHE_VALID|${PROXY_CACHE_VALID-}|" /etc/nginx/nginx.conf
nginx -t || nginx -T
nginx -t || exit 1
unbound -dd -c /etc/unbound.conf &
sleep 1

nslookup $REALUPSTREAM 127.0.0.1
#nginx -T |grep listen
nginx -T|grep -e server -e proxy_redirect

sleep 3;

cat /rp1.yaml;sleep 0.5

while (true);do 
  /usr/local/bin/rp --config /rp1.yaml  serve ;sleep 3
done &
cat /rp2.yaml

while (true);do 
  /usr/local/bin/rp --config /rp2.yaml  serve ;sleep 3
done &

export UPSTREAM_URL="http://127.0.0.1:$NGXPORT"
export LOG_LEVEL=info
#verbosity: trace, debug, info, warn, error, fatal, panic (default info)
export ATTEMPT_HTTP2=false
export TTL=2160m
export FRONTEND_URL=":"${PORT}
#export BACKEND_URL=redis://var/run/redis/redis.sock
#export BACKEND_URL=redis-socket://var/run/redis/redis.sock
export BACKEND_URL=redis://127.0.0.1:6379

ls -lh1 /usr/bin/cache-proxy
while (true);do 
  /usr/bin/cache-proxy 2>&1 |grep -v -e "HIT GET.*/healthcheck (200)" ;sleep 3
done &


#exec "$@" 

ash /nginx.sh