#set -x
#!/bin/bash


JENKINS_URL="http://localhost:$(kubectl get svc jenkins-service -n jenkins -o jsonpath="{.spec.ports[0].nodePort}")"
USER="admin"
PASSWORD="$(kubectl exec --namespace jenkins -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo)"
TOKEN_NAME="ShellToken"
COOKIE_JAR="/home/kubeuser/jenkins_cookies.txt"


echo
echo "------------------------------------------"
echo "GET THE CRUMB AND SAVE SESSION COOKIES"
CRUMB=$(curl -s -u "$USER:$PASSWORD" \
             --cookie-jar "$COOKIE_JAR" \
             "$JENKINS_URL/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,%22:%22,//crumb)")


echo
echo "------------------------------------------"
echo "GENERATING NEW API TOKEN"
API_TOKEN=$(curl -s -u "$USER:$PASSWORD" \
                 -H "$CRUMB" \
                 --cookie "$COOKIE_JAR" \
                 -X POST \
                 --data "newTokenName=$TOKEN_NAME" \
                 "$JENKINS_URL/me/descriptorByName/jenkins.security.ApiTokenProperty/generateNewToken" \
                 | jq -r '.data.tokenValue')
echo "$API_TOKEN"


echo
echo "------------------------------------------"
echo "CLEAN IP COOKIE FILE"
rm -f "$COOKIE_JAR"


exit 0