IGS=`gcloud compute instance-groups list --uri | grep -iE "gke-.*grp"`
# echo $IGS
AIGS=(`echo $IGS | tr ',' ' '| tr '"' ' '`)
#echo ${AIGS[0]} $AIGS[3] 
#echo ${#AIGS[@]}
#FAIGS=`jq --compact-output --null-input '$ARGS.positional' --args -- "${AIGS[@]}"`
#echo $FAIGS
for (( i=0; i<${#AIGS[@]}; i++ )); do
#echo ${AIGS[$i]}
gcloud compute instance-groups set-named-ports "${AIGS[$i]}" --named-ports=http:31025 > /dev/null
done
