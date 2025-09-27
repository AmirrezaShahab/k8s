#k8s Setup
swapoff -a
#/etc/fstab  is command

#Set timezone
timedatectl set-timezone Asia/Tehran

##Install containerd

wget https://github.com/containerd/containerd/releases/download/v2.1.4/containerd-2.1.4-linux-amd64.tar.gz

tar Czxvf /usr/local <containerd>

## Add service

vim /usr/lib/systemd/system/containerd.service

[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target dbus.service

[Service]
ExecStartPre=-/sbin/modprobe overlay
ExecStart=/usr/local/bin/containerd

Type=notify
Delegate=yes
KillMode=process
Restart=always
RestartSec=5

LimitNPROC=infinity
LimitCORE=infinity

TasksMax=infinity
OOMScoreAdjust=-999

[Install]
WantedBy=multi-user.target


## setup runc
wget https://github.com/opencontainers/runc/releases/download/v1.3.0/runc.amd64

install -m 755 runc.amd64 /usr/local/sbin/runc

mkdir -p /etc/containerd

containerd config default | sudo tee /etc/containerd/config.toml

##install cni for containerd

wget https://github.com/containernetworking/plugins/releases/download/v1.7.1/cni-plugins-linux-amd64-v1.7.1.tgz

mkdir -p /opt/cni/bin

tar Cxzvf /opt/cni/bin/ cni-plugins-linux-amd64-v1.8.0.tgz

##edite /etc/containerd/config.toml

; Containerd versions 2.x:

; [plugins.'io.containerd.cri.v1.runtime'.containerd.runtimes.runc]
;   ...
;   [plugins.'io.containerd.cri.v1.runtime'.containerd.runtimes.runc.options]
;     SystemdCgroup = true

## https://kubernetes.io/docs/setup/production-environment/container-runtimes/#containerd

## add systemdCgroup = true

systemctl restart containerd.service


# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system
Verify that net.ipv4.ip_forward is set to 1 with:

sysctl net.ipv4.ip_forward


## Install kubeadm v 1.32

#https://v1-32.docs.kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

sudo apt-get install -y apt-transport-https ca-certificates curl gpg

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

sudo systemctl enable --now kubelet


##kubeadm init

kubeadm init --pod-network-cidr=10.10.0.0/16 --apiserver-advertise-address=<ip master> --kubernetes-version 1.32.8

##Complition
#source <(kubectl completion bash) --> kubectl auto complete
#echo 'source <(kubectl completion bash)' >> ~/.bashrc



