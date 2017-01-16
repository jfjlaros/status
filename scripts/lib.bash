scale() {
  # Convert a value to a percentage.
  value=${1}
  minimum=${2}
  maximum=${3}

  echo $(((value - minimum) * 100 / (maximum - minimum)))
}

pick_colour() {
  # Convert a percentage to a colour in the range green to red.
  percentage=${1}

  red=255
  green=255
  if [ ${percentage} -lt 50 ]; then
    red=$((percentage * 255 / 50))
  else
    green=$(((100 - percentage) * 255 / 50))
  fi

  printf "#%02x%02x00\n" ${red} ${green}
}

pick_icon() {
  # Convert a percentage to an icon.
  percentage=${1}
  icons=${2}

  number_of_icons=${#icons}
  position=$((percentage * number_of_icons / 101))
  echo ${icons:position:1}
}

format_info() {
  icons=${1}
  value=${2}
  info=${3}
  invert=${4-false}
  minimum=${5-0}
  maximum=${6-100}

  percentage=$(scale ${value} ${minimum} ${maximum})
  icon=$(pick_icon ${percentage} ${icons}) 
  if [ ${invert} == "true" ]; then
    colour=$(pick_colour $((100 - ${percentage})))
  else
    colour=$(pick_colour ${percentage})
  fi

  info_string="${icon} ${info}"
  echo "${info_string}"
  echo "${info_string}"
  echo ${colour}
}
