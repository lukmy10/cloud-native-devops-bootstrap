#set -x
#!/bin/bash


echo
echo "CALICO installation gives network and network policies / popular CNA controller"
echo
echo "------------------------------------------"


kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/calico.yaml
echo
echo "------------------------------------------"
echo "CALICO ROLLOUT STATUS"
echo
kubectl rollout status deployment/calico-kube-controllers -n kube-system
kubectl rollout status daemonset/calico-node
kubectl get pods -n kube-system


sleep 30


exit 0