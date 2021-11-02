sudo echo "192.168.1.11 mongodb-node-1" | sudo tee -a /etc/hosts
sudo echo "192.168.1.12 mongodb-node-2" | sudo tee -a /etc/hosts
sudo echo "192.168.1.13 mongodb-node-3" | sudo tee -a /etc/hosts
sudo apt update && sudo apt upgrade -y
sudo apt install wget gnupg -y
wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-5.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org
sudo apt-get install -y mongodb-org
sudo systemctl enable mongod
sudo systemctl daemon-reload
sudo systemctl start mongod

mongo
use admin
db.createUser({user: "mongo-admin", pwd: "password", roles:[{role: "root", db: "admin"}]})
exit

sudo -s
openssl rand -base64 756 > /opt/mongo-keyfile (only node 1), copy ke node lain
chmod 400 /opt/mongo-keyfile
chown mongodb:mongodb /opt/mongo-keyfile
exit

sudo vi /etc/mongod.conf

```
net:
  port: 27017
  bindIp: 127.0.0.1,mongodb-node-1

replication:
  replSetName: "rs0"

security:
  keyFile: /opt/mongo-keyfile
```

sudo systemctl restart mongod

mongo -u mongo-admin -p --authenticationDatabase admin

rs.initiate()
rs.add("mongodb-node-2")
rs.add("mongodb-node-3")
