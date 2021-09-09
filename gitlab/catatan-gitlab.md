1. sudo yum update -y
2. sudo yum install yum-utils curl openssh-server ca-certificates postfix -y
3. sudo systemctl enable postfix.service
4. sudo systemctl start postfix.service
5. sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
6. sudo yum install docker-ce docker-ce-cli containerd.io -y
7. sudo systemctl start docker
8. sudo usermod -aG docker vagrant
9. logout, login
10. docker info
11. curl -s https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh | sudo bash
12. sudo yum install gitlab-ce -y
13. openssl req -newkey rsa:4096 -nodes -sha256 -keyout gitlab.local.p.key -addext "subjectAltName = DNS:gitlab.local.p" -x509 -days 365 -out gitlab.local.p.crt

14. sudo vi /etc/gitlab/gitlab.rb
- external_url 'https://gitlab.local.p'
- registry_external_url 'https://registry.gitlab.local.p:5005'
- registry['health_storagedriver_enabled'] = false
- nginx['ssl_certificate'] = "/etc/gitlab/ssl/gitlab.local.p.crt"
- nginx['ssl_certificate_key'] = "/etc/gitlab/ssl/gitlab.local.p.key"
- registry_nginx['ssl_certificate'] = "/etc/gitlab/ssl/gitlab.local.p.crt"
- registry_nginx['ssl_certificate_key'] = "/etc/gitlab/ssl/gitlab.local.p.key"

15. sudo gitlab-ctl reconfigure
16. sudo gitlab-rake "gitlab:password:reset"
17. curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.rpm.sh" | sudo bash
18. sudo yum install gitlab-runner -y
19. sudo gitlab-runner register --url http://192.168.1.3/ --registration-token $REGISTRATION_TOKEN

## for docker client

1. cp gitlab.local.p.crt /etc/docker/certs.d/gitlab.local.p:5005/ca.crt
2. sudo vi /etc/docker/daemon.json
```json
{
  "insecure-registries" : ["gitlab.local.p:5005"]
}
```
3. sudo systemctl restart docker