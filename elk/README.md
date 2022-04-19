## Elasticsearch

sudo apt-get install openjdk-8-jre-headless
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo apt-get install apt-transport-https
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-7.x.list
sudo apt-get update && sudo apt-get install elasticsearch
sudo vi /etc/elasticsearch/elasticsearch.yml

```
network.host: 0.0.0.0
http.port: 9200

discovery.type: single-node
```

sudo vi /etc/elasticsearch/jvm.options

```
-Xms512m
-Xmx512m
```

sudo systemctl start elasticsearch.service
sudo systemctl status elasticsearch.service
sudo systemctl enable elasticsearch.service
curl -X GET "localhost:9200"

## Kibana

sudo apt-get install kibana
sudo vi /etc/kibana/kibana.yml


```
server.port: 5601
server.host: "0.0.0.0"
elasticsearch.hosts: ["http://localhost:9200"]
```

sudo systemctl start kibana
sudo systemctl status kibana
sudo systemctl enable kibana

## Logstash

sudo apt-get install logstash

sudo vi /etc/logstash/conf.d/logstash.conf

```
input {
	beats {
		port => 5044
	}

	tcp {
		port => 5000
	}
	udp {
		port => 5144
	}
}

## Add your filters / logstash plugins configuration here

output {
	elasticsearch {
		hosts => "localhost:9200"
	}
}
```

sudo systemctl start logstash
sudo systemctl status logstash
sudo systemctl enable logstash
