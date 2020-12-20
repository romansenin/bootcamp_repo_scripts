#!/usr/bin/env bash
function reFormatNum() {
  argLength=${#1}

  if [[ argLength -eq 1 ]]; then
    echo "0${1}"
  else
    echo $1
  fi
}

if [[ "$#" -ne 1 ]]; then
  echo "Usage: ./solutionsToHomework.sh [Week Number]"
else
  # load path vars $pathtoContent and $pathToStudentRepo
  DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
  source "${DIR}/.env"

  weekNum=$(reFormatNum $1)

  if [[ -n "$(ls ${pathToContent}/01*/${weekNum}*/02*/Main 2>/dev/null)" ]]; then
    cp -r ${pathToContent}/01*/${weekNum}*/02*/Main ${pathToStudentRepo}/${weekNum}*/02*

    source=$(echo ${pathToContent}/01*/${weekNum}*/02*/Main | sed -E 's/.*01-Class-Content\/(.*)/\1/')
    destination=$(echo ${pathToStudentRepo}/${weekNum}*/02* | sed -E 's/^.*(UCD.*)/\1/')

    barLength=$((${#source} + ${#destination} + 4))

    printf '%.0s-' $(seq 1 $barLength)
    printf '\n'
    printf "$source -> $destination"
    printf '\n'
    printf '%.0s-' $(seq 1 $barLength)
    printf '\n\n'
  else
    week=$(echo ${pathToContent}/01*/${weekNum}*/02* | sed -E 's/.*01-Class-Content\/(.*)/\1/')
    tail="/Main Not Found"
    barLength=$((${#week} + ${#tail}))

    printf '%.0s-' $(seq 1 $barLength)
    printf '\n'
    echo "${week}${tail}"
    printf '%.0s-' $(seq 1 $barLength)
    printf '\n\n'
  fi 
fi