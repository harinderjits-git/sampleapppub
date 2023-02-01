


# Step#1 - Parse the input
#eval "$(jq -r '@sh "ipcidr=\(.ipcidr)"')"
ipcidr="40.70.151.96/27"
first_assignable_host=`curl https://networkcalc.com/api/ip/${ipcidr} 2>/dev/null | jq -r .address.first_assignable_host`

last_assignable_host=`curl https://networkcalc.com/api/ip/${ipcidr} 2>/dev/null | jq -r .address.last_assignable_host`



jq -n --arg first_assignable_host "$first_assignable_host" \
     --arg last_assignable_host "$last_assignable_host" \
      '{"first_assignable_host": $first_assignable_host, "last_assignable_host": $last_assignable_host}'
