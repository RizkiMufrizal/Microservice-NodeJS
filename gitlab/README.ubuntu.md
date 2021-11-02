1. sudo apt update && sudo apt upgrade -y
2. sudo apt install -y curl openssh-server ca-certificates tzdata perl postfix apt-transport-https gnupg lsb-release
3. curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
4. echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
5. sudo apt update
6. sudo apt install -y docker-ce docker-ce-cli containerd.io
7. sudo systemctl start docker
8. sudo usermod -aG docker vagrant
9. logout, login
10. docker info
11. curl -s https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash
12. sudo apt install -y gitlab-ce
13. openssl req -newkey rsa:4096 -nodes -sha256 -keyout gitlab.local.p.key -addext "subjectAltName = DNS:gitlab.local.p" -x509 -days 365 -out gitlab.local.p.crt

14. sudo vi /etc/gitlab/gitlab.rb
- external_url 'https://gitlab.local.p'
- registry_external_url 'https://gitlab.local.p:5005'
- registry['health_storagedriver_enabled'] = false
- nginx['ssl_certificate'] = "/etc/gitlab/ssl/gitlab.local.p.crt"
- nginx['ssl_certificate_key'] = "/etc/gitlab/ssl/gitlab.local.p.key"
- registry_nginx['ssl_certificate'] = "/etc/gitlab/ssl/gitlab.local.p.crt"
- registry_nginx['ssl_certificate_key'] = "/etc/gitlab/ssl/gitlab.local.p.key"
- gitlab_rails['smtp_enable'] = true
- gitlab_rails['smtp_address'] = "smtp.server"
- gitlab_rails['smtp_port'] = 465
- gitlab_rails['smtp_user_name'] = "smtp user"
- gitlab_rails['smtp_password'] = "smtp password"
- gitlab_rails['smtp_domain'] = "example.com"
- gitlab_rails['smtp_authentication'] = "login"
- gitlab_rails['smtp_enable_starttls_auto'] = true
- gitlab_rails['smtp_openssl_verify_mode'] = 'peer'
- gitlab_rails['gitlab_email_from'] = 'gitlab@example.com'
- gitlab_rails['gitlab_email_reply_to'] = 'noreply@example.com'

15. sudo gitlab-ctl reconfigure
16. sudo more /etc/gitlab/initial_root_password or sudo gitlab-rake "gitlab:password:reset"
17. curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | sudo bash
18. sudo apt-get install -y gitlab-runner
19. registration token (https://gitlab.local.p/admin/runners), 

sudo gitlab-runner register \
--url https://gitlab.local.p \
--executor shell \
--description "Gitlab Runner" \
--tls-ca-file /etc/gitlab/ssl/gitlab.local.p.crt \
--registration-token $REGISTRATION_TOKEN

20. sudo usermod -aG docker gitlab-runner
21. sudo -u gitlab-runner -H docker info

## for docker client and server gitlab

1. cp gitlab.local.p.crt /etc/docker/certs.d/gitlab.local.p:5005/ca.crt
2. sudo vi /etc/docker/daemon.json
```json
{
  "insecure-registries" : ["gitlab.local.p:5005"]
}
```
3. sudo systemctl restart docker

## for developer

1. git config --global http.sslVerify false (jika menggunakan self sign certificate)
2. docker login gitlab.local.p:5005
