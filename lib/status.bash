scale() {
  # Convert a value to a percentage.
  local value=${1}
  local minimum=${2}
  local maximum=${3}

  echo $(((value - minimum) * 100 / (maximum - minimum)))
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
  local time_file="/run/user/${UID}/i3/${1}"

  date "+%s" > ${time_file}
}

get_timer() {
  # Check if the timer has been running for longer than a certain duration.
  local time_file="/run/user/${UID}/i3/${1}"
  local duration=${2}

  local timer_start=$(cat ${time_file})
  local now=$(date "+%s")

  if [ $((now - timer_start + 1)) -gt ${duration} ]; then
    rm ${time_file}
    return 1
  fi
  return 0
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
