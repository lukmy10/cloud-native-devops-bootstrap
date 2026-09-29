#set -x
#!/bin/bash


if [ "$(id -u)" -ne 0 ]; then
  echo "EXECUTE WITH SUDO"
  exit 1
fi


#echo "ENTER USER NAME KUBEADM TO BE USED"
#read NAME


NAME="kubeuser"


if [ -f "/etc/modules-load.d/k8s.conf" ]; then
  echo
  echo "------------------------------------------"
  echo "MODULES K8S.CONF FILE EXIST"
else
  cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
  echo
  echo "------------------------------------------"
  echo "MODULES K8S.CONF FILE CREATED"
fi


modprobe overlay
modprobe br_netfilter
echo
echo "------------------------------------------"
echo "CHECK LSMOD"
lsmod | grep -i br
lsmod | grep -i over


if [ -f "/etc/sysctl.d/k8s.conf" ];then
  echo
  echo "------------------------------------------"
  echo "SYSCTL K8S.CONF FILE EXIST"
else
  cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
  echo
  echo "------------------------------------------"
  echo "SYSCTL K8S.CONF FILE CREATED"
fi


echo
echo "------------------------------------------"
echo "CHECK SYSCTL"
result_sysctl_br=$(sysctl --system | grep -i bridge)
echo "$result_sysctl_br"
result_sysctl_ipv=$(sysctl --system | grep -i ipv4.ip)
echo "$result_sysctl_ipv"
echo

sleep 30

apt-get install -y containerd
sleep 20
echo
echo "------------------------------------------"
echo "CHECK CONTAINERED IS INSTALLED"
apt list --installed containerd


mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml > /dev/null
echo
echo "------------------------------------------"
echo "CONTAINERD CONFIG FILE EXIST"
ls -l /etc/containerd/ | grep -v total


sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
echo
echo "------------------------------------------"
echo "SYSTEMDCGROUP = TRUE"
cat /etc/containerd/config.toml | grep -i SystemdCgroup


systemctl enable containerd.service
systemctl restart containerd.service
echo
echo "------------------------------------------"
echo "CONTAINERD SERVICE STATUS IS RUNNING"
systemctl status containerd.service | grep -i Active


swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
echo
echo "------------------------------------------"
echo "CHECK SWAP STATUS"
free -h


apt-get install -y apt-transport-https ca-certificates curl gpg > /dev/null
echo
echo "------------------------------------------"
echo "CHECK APT-TRANSPORT-HTTPS CA-CERTIFICATES CURL GPG ARE INSTALLED"
apt list --installed apt-transport-https ca-certificates curl gpg


mkdir -p -m 755 /etc/apt/keyrings


if [ -f "/etc/apt/keyrings/kubernetes-apt-keyring.gpg" ]; then
  echo
  echo "------------------------------------------"
  echo "APT KEYRING KUBERNETES FILE EXIST"
else
  curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
  echo
  echo "------------------------------------------"
  echo "APT KEYRING KUBERNETES FILE CREATED"
  ls -l /etc/apt/keyrings/kubernetes-apt-keyring.gpg | grep -v total
fi


if [ -f "/etc/apt/sources.list.d/kubernetes.list" ]; then
  echo
  echo "------------------------------------------"
  echo "REPO KUBERNETES FILE EXIST"
else
  echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" | tee /etc/apt/sources.list.d/kubernetes.list > /dev/null
  echo
  echo "------------------------------------------"
  echo "REPO KUBERNETES FILE CREATED"
  ls -l /etc/apt/sources.list.d/kubernetes.list | grep -v total
fi


apt-get update
sleep 20
apt-get install -y kubelet kubeadm kubectl
echo
sleep 20
echo
echo "------------------------------------------"
echo "CHECK KUBELET KUBEADM KUBECTL ARE INSTALLED"
apt list --installed kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl > /dev/null


echo
echo "------------------------------------------"
echo "KUBERNETES WORKER CONFIGURED"
echo "GET JOIN COMMAND WITH kubeadm token create --print-join-command EXECUTE ON CONTROLPLANE NODE"
echo "JOIN WORKER WITH CLUSTER"


exit 0