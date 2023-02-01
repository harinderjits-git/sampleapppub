#!/bin/bash

# Step#1 - Parse the input
eval "$(jq -r '@sh "gke=\(.gke) region=\(.region) project=\(.project)"')"
#eval "$(jq -r '@sh "FOO=\(.foo) BAZ=\(.baz)"')"

#gke="sampleappprodprimarygkeue"
# project=mysampleappproj1-ffgd12345
# region=us-east4
# gke="sampleappproddrgkeue2"

context=gke_${project}_${region}_${gke}

#kubectl config unset > /dev/null

gcloud container clusters get-credentials $gke --region $region --project $project >/dev/null
kubectl config use-context ${context} > /dev/null
IP_ADDRESS=`kubectl get svc httpappgcp -o json -n httpapp | jq -r .status.loadBalancer.ingress[0].ip`
IP_ADDRESS_AKS=(`echo $IP_ADDRESS | tr ',' ' '| tr '"' ' '`)
# Create a JSON object and pass it back


case ${#IP_ADDRESS_AKS[@]}  in
   1)
      jq -n --arg ip_address_gke "$IP_ADDRESS_AKS" \
      '{"ip_address_gke": $ip_address_gke}'
      ;;
   *)  jq -n  \
      '{"ip_address_gke": ""}'
      ;;
esac