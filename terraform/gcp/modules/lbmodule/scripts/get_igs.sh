IGS=`gcloud compute instance-groups list --uri | grep -iE "gke-.*grp"`
# echo $IGS
AIGS=(`echo $IGS | tr ',' ' '| tr '"' ' '`)
#echo ${AIGS[0]} $AIGS[3] 
#echo ${#AIGS[@]}
#FAIGS=`jq --compact-output --null-input '$ARGS.positional' --args -- "${AIGS[@]}"`
#echo $FAIGS
for (( i=0; i<=${#AIGS[@]}; i++ )); do
     gcloud compute instance-groups set-named-ports "${AIGS[$i]}" --named-ports=http:31025 > /dev/null
done


case ${#AIGS[@]}  in
   3)
      jq -n \
      --arg mig1 ${AIGS[0]} \
      --arg mig1 ${AIGS[1]} \
      --arg mig2 ${AIGS[2]} \
      '{"mig1": $mig1, "mig2": $mig2, "mig3": $mig3, "mig4": "","mig5": "","mig6": ""}'
      ;;
   6)
      jq -n \
      --arg mig1 ${AIGS[0]} \
      --arg mig2 ${AIGS[1]} \
      --arg mig3 ${AIGS[2]} \
      --arg mig4 ${AIGS[3]} \
      --arg mig5 ${AIGS[4]} \
      --arg mig6 ${AIGS[5]} \
      '{"mig1": $mig1, "mig2": $mig2, "mig3": $mig3, "mig4": $mig4,"mig5": $mig5,"mig6": $mig6}'
      ;;

   *)
      jq -n '{"mig1": "", "mig2": "", "mig3": "", "mig4": "","mig5": "","mig6": ""}'
     ;;
esac
