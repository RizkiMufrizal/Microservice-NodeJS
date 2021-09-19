1. sudo yum install https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm -y
2. sudo yum install postgresql96 -y
3. sudo yum install postgresql96-server -y
4. sudo /usr/pgsql-9.6/bin/postgresql96-setup initdb
5. sudo systemctl enable postgresql-9.6
6. sudo systemctl start postgresql-9.6
7. sudo -i -u postgres
8. psql
9. CREATE USER kong; CREATE DATABASE kong OWNER kong; ALTER USER kong WITH password 'kong';
10. CREATE USER konga; CREATE DATABASE konga OWNER konga; ALTER USER konga WITH password 'konga';
11. sudo vi /var/lib/pgsql/9.6/data/pg_hba.conf

```text

IPv4 local	host	all	all	0.0.0.0/0	md5
```

12. sudo vi /var/lib/pgsql/9.6/data/postgresql.conf

```text
listen_addresses = '*'
```

13. sudo systemctl restart postgresql-9.6
14. download rpm dari https://download.konghq.com/gateway-2.x-centos-7/Packages/k/kong-2.5.1.el7.amd64.rpm
15. sudo yum install kong-2.5.1.el7.amd64.rpm -y
16. sudo cp /etc/kong/kong.conf.default /etc/kong/kong.conf
17. sudo vi /etc/kong/kong.conf

```text
database = postgres
pg_host = kong.local
pg_port = 5432
pg_user = kong
pg_password = kong
pg_database = kong

admin_access_log = logs/admin_access.log
admin_error_log = logs/error.log
admin_listen = 0.0.0.0:8001 reuseport backlog=16384, 0.0.0.0:8444 http2 ssl reuseport backlog=16384
proxy_listen = 0.0.0.0:8000 reuseport backlog=16384, 0.0.0.0:8443 http2 ssl reuseport backlog=16384

```

18. sudo vi /etc/security/limits.conf

```text

*      soft   nofile      1048576
*      hard   nofile      1048576
```

19. sudo KONG_PASSWORD=P@ssw0rd /usr/local/bin/kong migrations bootstrap -c /etc/kong/kong.conf
20. sudo cp kong.service /etc/systemd/system
21. sudo systemctl daemon-reload
22. sudo systemctl enable kong.service
23. sudo systemctl start kong.service
24. docker run -p 1337:1337 -e "DB_ADAPTER=postgres" -e "DB_HOST=192.168.1.4" -e "DB_PORT=5432" -e "DB_USER=konga" -e "DB_PASSWORD=konga" -e "DB_DATABASE=konga" -e "NODE_ENV=development" -e "DB_PG_SCHEMA=public" --name konga pantsel/konga
25. curl -i -X GET --url http://kong.local:8001/services
26. log -> /usr/local/kong/logs