input=$1

step="0"
# 0 - looking for "Received: "
# 1 - looking for domain
# 2 - looking for day of month
# 3 - looking for time
# 4 - done
domain=""
time=""
timeStep="5"

while  read -r -a words; do
  for word in "${words[@]}"; do
    if [[ "$step" = "4" ]]; then
      step="0"
      printf "%s\t\t%s\n" "$time" "$domain"
      time=""
      domain=""
    fi
    if [[ "$step" = "3" ]]; then
      if [[ $(echo "${#word} < 2" | bc) = "1" ]]; then
        word="0$word"
      fi
      time="$time $word"
      timeStep=$(echo "$timeStep - 1" | bc)
      if [[ "$timeStep" = "0" ]]; then
        timeStep="5"
        step=$(echo "$step + 1" | bc)
      fi
    fi
    if [[ "$step" = "2" ]]; then
      if [[ -n "$(echo "$word" | grep -E "^(Mon|Tue|Wed|Thu|Fri|Sat|Sun),$")" ]]; then
        time="$word"
        step=$(echo "$step + 1" | bc)
      fi
    fi
    if [[ "$step" = "1" ]]; then
      if [[ -n "$(echo "$word" | grep -E "^\[?([-a-zA-Z0-9]+\.)+[-a-zA-Z0-9]+\]?$")" ]]; then
        domain="$word"
        step=$(echo "$step + 1" | bc)
      fi
    fi
    if [[ "$step" = "0" ]]; then
      if [[ -n "$(echo "$word" | grep -E "^Received:$")" ]]; then
        step=$(echo "$step + 1" | bc)
      fi
    fi
  done
done <$input || (( ${#words[@]} ))
