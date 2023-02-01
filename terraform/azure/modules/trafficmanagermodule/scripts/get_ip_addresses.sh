#!/bin/bash

# Step#1 - Parse the input
eval "$(jq -r '@sh "aks=\(.aks)"')"
#aks="sampleappprodprimaryaksue"
#aks="sampleappproddraksue2"


#authenticate
#az account set --subscription <subid>
#kubectl config unset > /dev/null
KUBECONFIG=$HOME/kubeconfig
az aks get-credentials --resource-group ${aks}-rg --name ${aks}  --admin --overwrite-existing -f $HOME/kubeconfig
IP_ADDRESS=`KUBECONFIG=$HOME/kubeconfig kubectl get svc httpapp -o json -n httpapp | jq -r .status.loadBalancer.ingress[0].ip`
IP_ADDRESS_AKS=(`echo $IP_ADDRESS | tr ',' ' '| tr '"' ' '`)
# Create a JSON object and pass it back
rm -rf $HOME/kubeconfig

case ${#IP_ADDRESS_AKS[@]}  in
   1)
      jq -n --arg ip_address_aks "$IP_ADDRESS_AKS" \
      '{"ip_address_aks": $ip_address_aks}'
      ;;
   *)  jq -n  \
      '{"ip_address_aks": ""}'
      ;;
esac