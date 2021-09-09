sudo yum update -y

sudo yum install yum-utils curl openssh-server ca-certificates postfix -y
sudo systemctl enable postfix.service
sudo systemctl start postfix.service

sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker-ce docker-ce-cli containerd.io -y
sudo systemctl start docker
sudo usermod -aG docker vagrant
logout, login
docker info

curl -s https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh | sudo bash
sudo yum install gitlab-ce -y

openssl req -newkey rsa:4096 -nodes -sha256 -keyout gitlab.local.p.key -addext "subjectAltName = DNS:gitlab.local.p" -x509 -days 365 -out gitlab.local.p.crt

sudo vi /etc/gitlab/gitlab.rb
- external_url 'https://gitlab.local.p'
- registry_external_url 'https://registry.gitlab.local.p:5005'
- registry['health_storagedriver_enabled'] = false
- nginx['ssl_certificate'] = "/etc/gitlab/ssl/gitlab.local.p.crt"
- nginx['ssl_certificate_key'] = "/etc/gitlab/ssl/gitlab.local.p.key"
- registry_nginx['ssl_certificate'] = "/etc/gitlab/ssl/gitlab.local.p.crt"
- registry_nginx['ssl_certificate_key'] = "/etc/gitlab/ssl/gitlab.local.p.key"

sudo gitlab-ctl reconfigure
sudo gitlab-rake "gitlab:password:reset"

curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.rpm.sh" | sudo bash
sudo yum install gitlab-runner -y
sudo gitlab-runner register --url http://192.168.1.3/ --registration-token $REGISTRATION_TOKEN

# for client
cp gitlab.local.p.crt /etc/docker/certs.d/gitlab.local.p:5005/ca.crt
sudo vi /etc/docker/daemon.json
{
  "insecure-registries" : ["gitlab.local.p:5005"]
}
sudo systemctl restart docker
