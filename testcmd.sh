docker stop test & 

git pull ;
docker build . -t tst ;
fg;
wait;
docker ps -a|grep test && sleep 2
docker run --name test --rm -t -e UPSTREAM=google.com -e MORE_UPSTREAMS=bing.com -e PORT=8080  -p 8080:8080  tst &
sleep 5;curl 127.0.0.1:8080/index.html