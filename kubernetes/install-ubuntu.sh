# requirment
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo swapoff -a

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system

sudo apt update && sudo apt upgrade -y
sudo apt install -y curl openssh-server ca-certificates apt-transport-https
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y containerd.io=1.2.13-2 docker-ce=5:19.03.11~3-0~ubuntu-focal docker-ce-cli=5:19.03.11~3-0~ubuntu-focal
sudo mkdir /etc/docker
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF
sudo systemctl enable docker
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo usermod -aG docker vagrant

#kubernetes

sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Config Kubernetes

sudo -s
swapoff -a
# Jika hanya 1 control panel
kubeadm init --apiserver-advertise-address=192.168.100.32 --pod-network-cidr=10.244.0.0/16

# Jika Cluster Control Panel
kubeadm init --control-plane-endpoint "10.5.5.79:6444" --upload-certs --pod-network-cidr=10.244.0.0/16
exit

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
#kubectl create -f https://docs.projectcalico.org/manifests/tigera-operator.yaml
kubectl get pods --all-namespaces

#disable node master jika tidak menggunakan cluster
kubectl taint nodes --all node-role.kubernetes.io/master-

kubeadm join 192.168.25.11:6443 --token yvgmu7.46ffw27b2s1fe0l9 \
  --discovery-token-ca-cert-hash sha256:6bab247baf47f7ca728b09036c98164c1c72d1f845dff8259446bc923f4d0719

# Config kubernetes Dashboard

# Install Metric Server
kubectl apply -f metric-server.yaml

# Install Kubernetes Dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.3.1/aio/deploy/recommended.yaml
kubectl patch svc kubernetes-dashboard --type='json' -p '[{"op":"replace","path":"/spec/type","value":"NodePort"}]' --namespace=kubernetes-dashboard
kubectl get svc --namespace=kubernetes-dashboard

# create account
kubectl apply -f kubernetes-account.yaml

# show token
kubectl -n kubernetes-dashboard get secret $(kubectl -n kubernetes-dashboard get sa/admin-user -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}"