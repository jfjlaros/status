. "/usr/share/i3blocks/status/lib/status.bash"

net_speed() {
  # Return a human readable network speed.
  local speed=${1}

  local units=" KMGT"

  for i in {4..1}; do
    local numerator=$((1024 ** i))

    if [ ${speed} -ge ${numerator} ]; then
      printf '%4i%cb' $((speed / numerator)) ${units:i:1}
      return
    fi
  done
  printf '%4ib ' ${speed}
}

get_delta() {
  local interface=${1}
  local direction=${2}

  local value=$(cat /sys/class/net/${interface}/statistics/${direction}_bytes)
  local ds=$(update_value ${interface}_${direction} ${value})
  local dt=$(update_time ${interface}_${direction})

  echo $(((ds * 8) / dt))
}

get_deltas() {
  local interface=${1}

  local delta_rx=$(net_speed $(get_delta ${interface} "rx"))
  local delta_tx=$(net_speed $(get_delta ${interface} "tx"))

  echo "${delta_rx} ${delta_tx}"
}
