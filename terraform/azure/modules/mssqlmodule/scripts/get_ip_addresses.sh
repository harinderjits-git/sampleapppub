#!/bin/bash

#authenticate
#az account set --subscription <subid>
MYIP=`curl https://api.ipify.org`
IP_ADDRESS_AKS=`az network public-ip list --query="[?tags.Solution=='sampleapp'].ipAddress"`
#IP_ADDRESS_AKS=`echo $IP_ADDRESS_AKS | jq -r`
IP_ADDRESSES=(`echo $IP_ADDRESS_AKS | tr ',' ' '| tr '"' ' '`)
# #testing
# for (( i=0; i<=${#IP_ADDRESSES[@]}; i++ )); do
#      echo "${IP_ADDRESSES[$i]}"
# done
# Create a JSON object and pass it back
case ${#IP_ADDRESSES[@]}  in
   3)
      jq -n --arg my_ip ${MYIP} \
      --arg ip_address_aks1 ${IP_ADDRESSES[1]} \
      '{"my_ip": $my_ip, "ip_address_aks1": $ip_address_aks1, "ip_address_aks2": "", "ip_address_aks3": "", "ip_address_aks4": ""}'
      ;;
   4)
      jq -n --arg my_ip ${MYIP} \
      --arg ip_address_aks1 ${IP_ADDRESSES[1]} \
      --arg ip_address_aks2 ${IP_ADDRESSES[2]} \
      '{"my_ip": $my_ip,"ip_address_aks1": $ip_address_aks1, "ip_address_aks2": $ip_address_aks2, "ip_address_aks3": "", "ip_address_aks4": ""}'
      ;;
   5)
      jq -n --arg my_ip ${MYIP} \
      --arg ip_address_aks1 ${IP_ADDRESSES[1]} \
      --arg ip_address_aks2 ${IP_ADDRESSES[2]} \
      --arg ip_address_aks3 ${IP_ADDRESSES[3]} \
      '{"my_ip": $my_ip,"ip_address_aks1": $ip_address_aks1,  "ip_address_aks2": $ip_address_aks2, "ip_address_aks3": $ip_address_aks3, "ip_address_aks4": ""}'
      ;;
   6)
     jq -n --arg my_ip ${MYIP} \
     --arg ip_address_aks1 ${IP_ADDRESSES[1]} \
      --arg ip_address_aks2 ${IP_ADDRESSES[2]} \
      --arg ip_address_aks3 ${IP_ADDRESSES[3]} \
      --arg ip_address_aks4 ${IP_ADDRESSES[4]} \
      '{"my_ip": $my_ip,"ip_address_aks1": $ip_address_aks1,  "ip_address_aks2": $ip_address_aks2,  "ip_address_aks3": $ip_address_aks3,  "ip_address_aks4": $ip_address_aks4 }'
     ;;
   *)
      jq -n --arg my_ip ${MYIP} '{"my_ip": $my_ip}'
     ;;
esac
