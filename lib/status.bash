_time_file() {
  echo "/run/user/${UID}/i3/$(basename ${0})_timer.dat"
}

_timestamp_file() {
  echo "/run/user/${UID}/i3/$(basename ${0})_${1}_timestamp.dat"
}

_pid_file() {
  echo "/run/user/${UID}/i3/$(basename ${0})_${1}_screen.pid"
}

_toggle_file() {
  echo "/run/user/${UID}/i3/$(basename ${0})_${1}_toggle.state"
}

_store_file() {
  echo "/run/user/${UID}/i3/$(basename ${0})_${1}_store.dat"
}

_min() {
  echo $((${1} < ${2} ? ${1} : ${2}))
}


scale() {
  # Convert a value to a percentage.
  local value=${1}
  local minimum=${2}
  local maximum=${3}

  echo $(_min $(((value - minimum) * 100 / (maximum - minimum))) 100)
}

pick_colour() {
  # Convert a percentage to a colour in the range green to red.
  local percentage=${1}

  local red=255
  local green=255

  if [ ${percentage} -lt 50 ]; then
    red=$((percentage * 255 / 50))
  else
    green=$(((100 - percentage) * 255 / 50))
  fi

  printf "#%02x%02x00\n" ${red} ${green}
}

pick_icon() {
  # Convert a percentage to an icon.
  local percentage=${1}
  local icons=${2}

  local number_of_icons=${#icons}
  local position=$((percentage * number_of_icons / 101))

  echo ${icons:position:1}
}

set_timer() {
  # Record the current time.
  date "+%s" > $(_time_file)
}

get_timer() {
  # Check if the timer has been running for longer than a certain duration.
  local duration=${1}

  local time_file=$(_time_file)

  if [ -s ${time_file} ]; then
    local timer_start=$(cat ${time_file})
    local now=$(date "+%s")

    if [ $((now - timer_start + 1)) -gt ${duration} ]; then
      rm ${time_file}
    else
      return 0
    fi
  fi
  return 1
}

key_command() {
  # Execute a command on key press.
  local button=${1}
  local cmd=${2}
  local args=${*:3}

  if [ ${BLOCK_BUTTON} == ${button} ]; then
    ${cmd} ${args}
  fi
}

key_toggle() {
  # Toggle a command on key press.
  local button=${1}
  local cmd=${2}
  local arg_on=${3}
  local arg_off=${4}

  local state_file=$(_toggle_file ${cmd})

  if [ ${BLOCK_BUTTON} == ${button} ]; then
    if [ -f ${state_file} ]; then
      ${cmd} ${arg_on}
      rm ${state_file}
    else
      touch ${state_file}
      ${cmd} ${arg_off}
    fi
  fi
}

key_toggle_status() {
  # Get the status of a toggle command.
  local cmd=${1}

  local state_file=$(_toggle_file ${cmd})

  if [ -f ${state_file} ]; then
    echo 100
    return
  fi
  echo 0
}

key_launch() {
  # Execute or kill a command on key press.
  local button=${1}
  local cmd=${2}
  local args=${*:3}

  if [ ${BLOCK_BUTTON} == ${button} ]; then
    local pid_file=$(_pid_file ${cmd})

    if [ -s ${pid_file} ]; then
      kill $(cat ${pid_file})
      rm ${pid_file}
    else
      touch ${pid_file}
      screen -d -m bash -c 'echo $$ > '${pid_file}'; '${cmd} ${args}
    fi
  fi
}

key_launch_running() {
  # Monitor a running application.
  local cmd=${1}

  local pid_file=$(_pid_file ${cmd})

  if [ -f ${pid_file} ]; then
    if [ -d /proc/$(cat ${pid_file}) ]; then
      echo 50
      return
    else
      rm ${pid_file}
    fi
  fi
  echo 0
}

store_time() {
  # Store the time for later use.
  local cmd=${1}

  date "+%s" > $(_timestamp_file ${cmd})
}

get_time() {
  # Retrieve a stored time value.
  local cmd=${1}

  local time_file=$(_timestamp_file ${cmd})
  if [ -s ${time_file} ]; then
    cat ${time_file}
  else
    echo 0
  fi
}

update_time() {
  # Update a stored time value and return the delta.
  local cmd=${1}

  local value=$(get_time ${cmd})
  store_time ${cmd}

  echo $(($(get_time ${cmd}) - value))
}

store_value() {
  # Store a value for later use.
  local cmd=${1}
  local value=${2}

  echo ${value} > $(_store_file ${cmd})
}

get_value() {
  # Retrieve a stored value.
  local cmd=${1}

  local store_file=$(_store_file ${cmd})

  if [ -s ${store_file} ]; then
    cat ${store_file}
  else
    echo 0
  fi
}

update_value() {
  # Update a stored value and return the delta.
  local cmd=${1}
  local value=${2}

  echo $((value - $(get_value ${cmd})))
  store_value ${cmd} ${value}
}

parse_args() {
  # Argument parser for the BLOCK_INSTANCE variable.
  local args=(${BLOCK_INSTANCE})

  local offset=0

  for arg in ${*}; do
    export $arg=${args[${offset}]}
    offset=$((offset + 1))
  done
}

format_info() {
  local icons=${1}
  local value=${2}
  local info=${3}
  local invert=${4-false}
  local minimum=${5-0}
  local maximum=${6-100}

  local percentage=$(scale ${value} ${minimum} ${maximum})
  local icon
  local colour
  local info_string

  if [ ${icons} ]; then
    icon="$(pick_icon ${percentage} ${icons}) "
  fi
  if [ ${invert} == "true" ]; then
    colour=$(pick_colour $((100 - ${percentage})))
  else
    colour=$(pick_colour ${percentage})
  fi

  info_string="${icon}${info}"
  echo "${info_string}"
  echo
  echo ${colour}
}
