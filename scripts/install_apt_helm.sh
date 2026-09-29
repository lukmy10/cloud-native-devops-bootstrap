#set -x
#!/bin/bash


if ! command -v curl &> /dev/null; then
    echo
    echo "------------------------------------------"
    echo "CURL NOT INSTELLED"
    sudo apt-get update && sudo apt-get install -y curl
    sleep 30
    apt list --installed curl
else
	echo
    echo "------------------------------------------"
    echo "CURL INSTALLED"
	apt list --installed curl
fi


if ! command -v jq &> /dev/null; then
    echo
    echo "------------------------------------------"
    echo "JQ NOT INSTELLED"
    sudo apt-get update && sudo apt-get install -y jq
    sleep 30
    apt list --installed jq
else
	echo
    echo "------------------------------------------"
    echo "JQ INSTALLED"
	apt list --installed jq
fi


echo
echo "------------------------------------------"
echo "GET HELM"
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash


exit 0