#set -x
#!/bin/bash


echo
echo "------------------------------------------"
echo "HELM VERSION"
helm version


echo
echo "------------------------------------------"
echo "ADD JENKINS AND BITNAMI HELM REPOS"
helm repo add jenkins https://charts.jenkins.io
helm repo add bitnami https://charts.bitnami.com/bitnami


echo
echo "------------------------------------------"
echo "HELM REPO UPDATE"
helm repo update


echo
echo "------------------------------------------"
echo "CHECK USER NAME"
whoami | tee $USER > /dev/null


echo
echo "------------------------------------------"
echo "CREATE LOCAL JENKINS DIRECTORY"
mkdir -p /home/$USER/jenkinsdir
chmod 777 /home/$USER/jenkinsdir


if [ -f "pv.yaml" ];then
  echo
  echo "------------------------------------------"
  echo "PV.YAML FILE EXIST"
else
  echo
  echo "------------------------------------------"
  echo "PV.YAML FILE CREATED"
  echo
  cat <<EOF | tee pv.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: jenkins-pv
spec:
  capacity:
    storage: 10Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: "/home/$USER/jenkinsdir"
EOF
fi


echo
echo "------------------------------------------"
echo "APPLY PERSISTENT VOLUME YAML"
kubectl apply -f pv.yaml


echo
echo "------------------------------------------"
echo "REMOVE PERSISTENT VOLUME YAML"
rm -rf pv.yaml


echo
echo "------------------------------------------"
echo "GET PERSISTENT VOLUME"
kubectl get pv


echo
echo "------------------------------------------"
echo "REMOVE CONTROLPLANE TAINT"
kubectl taint nodes $(hostname) node-role.kubernetes.io/control-plane:NoSchedule- || true


echo
echo "------------------------------------------"
echo "RESTART CALICO CONTROLLERS"
kubectl rollout restart deployment/calico-kube-controllers -n kube-system
kubectl rollout status deployment/calico-kube-controllers -n kube-system


echo
echo "------------------------------------------"
echo "RESTART CALICO NODE"
kubectl rollout restart daemonset/calico-node -n kube-system
kubectl rollout status daemonset/calico-node -n kube-system


echo
echo "------------------------------------------"
echo "INSTALL JENKINS WITH HELM IN JENKINS NAMESPACE"
helm install jenkins jenkins/jenkins --namespace jenkins --create-namespace --set controller.nodeSelector."kubernetes\.io/hostname"=$(hostname) || true


echo
echo "------------------------------------------"
echo "ROLLOUT JENKINS STATUS"
kubectl rollout status statefulset/jenkins -n jenkins --timeout=15m


echo
echo "------------------------------------------"
echo "GET PERSISTENT VOLUME"
kubectl get pv


echo
echo "------------------------------------------"
echo "EXPOSE JENKINS PORT"
kubectl expose pod jenkins-0 -n jenkins --type=NodePort --port=80 --target-port=8080 --name=jenkins-service


echo
echo "------------------------------------------"
echo "GET SERVICE PORT"
kubectl get service -n jenkins


echo
echo "------------------------------------------"
echo "SHOW JENKINS ADMIN PASSWORD"
kubectl exec --namespace jenkins -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo


echo
echo "------------------------------------------"
echo "CREATE JENKINS ROLEBINDINGS"
kubectl create rolebinding jenkins-admin-binding \
  --clusterrole=admin \
  --serviceaccount=jenkins:default \
  --namespace=jenkins


echo
echo "------------------------------------------"
echo "777 ON JENKINS DIRECTORY NEEDED DURING JENKINS RESTART"
chmod -R 777 /home/$USER/jenkinsdir


sleep 30


exit 0