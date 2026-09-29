#set -x
#!/bin/bash


echo
echo "------------------------------------------"
echo "KSERVER01R01 IP ADDRESS"
IP=$(curl -s ifconfig.me)
echo $IP


echo
echo "------------------------------------------"
echo "SERVER SSH LOGIN METHOD"
echo ssh root@$IP


echo
echo "------------------------------------------"
echo "JENKINS WEB PORT"
PORT=$(kubectl get svc jenkins-service -n jenkins -o jsonpath="{.spec.ports[0].nodePort}")
echo $PORT


echo
echo "------------------------------------------"
echo "JENKINS WEB LINK"
echo http://$IP:$PORT


echo
echo "------------------------------------------"
echo "JENKINS WEB USER"
echo admin


echo
echo "------------------------------------------"
echo "JENKINS WEB PASSWD"
PASSWD=$(kubectl exec --namespace jenkins -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo)
echo $PASSWD


exit 0