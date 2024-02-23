nginx -t
while (true);do nginx -g "daemon off;" |grep -v /healthcheck ;sleep 3;done