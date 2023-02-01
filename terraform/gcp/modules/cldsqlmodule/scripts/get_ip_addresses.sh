#!/bin/bash

#authenticate
#az account set --subscription <subid>
MYIP=`curl https://api.ipify.org`
IP_ADDRESS_GKE=`gcloud compute instances list --format='table(EXTERNAL_IP)'| grep -v EXTERNAL_IP`
#IP_ADDRESS_GKE=`echo $IP_ADDRESS_GKE | jq -r`
IP_ADDRESSES=(`echo $IP_ADDRESS_GKE | tr ',' ' '| tr '"' ' '`)
# #testing
# for (( i=0; i<=${#IP_ADDRESSES[@]}; i++ )); do
#     echo "${IP_ADDRESSES[$i]}"
# done

#echo ${#IP_ADDRESSES[@]}
# Create a JSON object and pass it back
case ${#IP_ADDRESSES[@]}  in
   1)
      jq -n --arg my_ip ${MYIP} \
      --arg ip_address_gke1 ${IP_ADDRESSES[0]} \
      '{"my_ip": $my_ip, "ip_address_gke1": $ip_address_gke1, "ip_address_gke2": "", "ip_address_gke3": "",  "ip_address_gke4": "", "ip_address_gke5": "", "ip_address_gke6": ""}'
      ;;
   2)
      jq -n --arg my_ip ${MYIP} \
      --arg ip_address_gke1 ${IP_ADDRESSES[0]} \
      --arg ip_address_gke2 ${IP_ADDRESSES[1]} \
      '{"my_ip": $my_ip,"ip_address_gke1": $ip_address_gke1, "ip_address_gke2": $ip_address_gke2, "ip_address_gke3": "",  "ip_address_gke4": "", "ip_address_gke5": "", "ip_address_gke6": ""}'
      ;;
   3)
      jq -n --arg my_ip ${MYIP} \
      --arg ip_address_gke1 ${IP_ADDRESSES[0]} \
      --arg ip_address_gke2 ${IP_ADDRESSES[1]} \
      --arg ip_address_gke3 ${IP_ADDRESSES[2]} \
      '{"my_ip": $my_ip,"ip_address_gke1": $ip_address_gke1,  "ip_address_gke2": $ip_address_gke2, "ip_address_gke3": $ip_address_gke3,  "ip_address_gke4": "", "ip_address_gke5": "", "ip_address_gke6": ""}'
      ;;
   4)
      jq -n --arg my_ip ${MYIP} \
      --arg ip_address_gke1 ${IP_ADDRESSES[0]} \
      --arg ip_address_gke2 ${IP_ADDRESSES[1]} \
      --arg ip_address_gke3 ${IP_ADDRESSES[2]} \
      --arg ip_address_gke4 ${IP_ADDRESSES[3]} \
      '{"my_ip": $my_ip,"ip_address_gke1": $ip_address_gke1,  "ip_address_gke2": $ip_address_gke2, "ip_address_gke3": $ip_address_gke3,  "ip_address_gke4": $ip_address_gke4, "ip_address_gke5": "", "ip_address_gke6": ""}'    ;;
   5)
      jq -n --arg my_ip ${MYIP} \
      --arg ip_address_gke1 ${IP_ADDRESSES[0]} \
      --arg ip_address_gke2 ${IP_ADDRESSES[1]} \
      --arg ip_address_gke3 ${IP_ADDRESSES[2]} \
      --arg ip_address_gke4 ${IP_ADDRESSES[3]} \
      --arg ip_address_gke5 ${IP_ADDRESSES[4]} \
      '{"my_ip": $my_ip,"ip_address_gke1": $ip_address_gke1,  "ip_address_gke2": $ip_address_gke2, "ip_address_gke3": $ip_address_gke3,  "ip_address_gke4":  $ip_address_gke4, "ip_address_gke5": $ip_address_gke5, "ip_address_gke6": ""}'      ;;
   6)
      jq -n --arg my_ip ${MYIP} \
      --arg ip_address_gke1 ${IP_ADDRESSES[0]} \
      --arg ip_address_gke2 ${IP_ADDRESSES[1]} \
      --arg ip_address_gke3 ${IP_ADDRESSES[2]} \
      --arg ip_address_gke4 ${IP_ADDRESSES[3]} \
      --arg ip_address_gke5 ${IP_ADDRESSES[4]} \
      --arg ip_address_gke6 ${IP_ADDRESSES[5]} \
      '{"my_ip": $my_ip,"ip_address_gke1": $ip_address_gke1,  "ip_address_gke2": $ip_address_gke2, "ip_address_gke3": $ip_address_gke3,  "ip_address_gke4": $ip_address_gke4, "ip_address_gke5": $ip_address_gke5, "ip_address_gke6": $ip_address_gke6}'
      ;;
   *)
      jq -n --arg my_ip ${MYIP} '{"my_ip": $my_ip}'
     ;;
esac
