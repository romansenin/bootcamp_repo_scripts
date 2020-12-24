#!/usr/bin/env bash
function reFormatNum() {
  argLength=${#1}

  if [[ argLength -eq 1 ]]; then
    echo "0${1}"
  else
    echo $1
  fi
}

# Display help messages if help flag passed
if [[ $1 == "-h" ]] || [[ $1 == "--help" ]]; then
  echo "[Week Number]         week number for the desired homework solution"
  echo "options:"
  echo "-h, --help            show brief help"
  echo "-c, --commit          commit the changes but do not push"
  echo "-p, --push            push algorithm solutions to dest origin"
  exit 0
fi

SHOULD_COMMIT=0
SHOULD_PUSH=0

# set SHOULD_COMMIT to 1 if commit flag passed
if [[ $1 == "-c" ]] || [[ $1 == "--commit" ]]; then
  SHOULD_COMMIT=1
  # pop the flag from the arguments list
  shift
fi

# set SHOULD_PUSH and SHOULD_COMMIT to 1 if push flag passed
if [[ $1 == "-p" ]] || [[ $1 == "--push" ]]; then
  SHOULD_PUSH=1
  SHOULD_COMMIT=1
  # pop the flag from the arguments list
  shift
fi

if [[ "$#" -ne 1 ]]; then
  echo "Usage: ./solutionsToHomework.sh [options] [Week Number]. Type -h or --help for more information."
else
  # load path vars $pathtoContent and $pathToStudentRepo
  DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
  source "${DIR}/.env"

  cd $pathToStudentRepo

  weekNum=$(reFormatNum $1)

  if [[ -n "$(ls ${pathToContent}/01*/${weekNum}*/02*/Main 2>/dev/null)" ]]; then
    # undo any changes in homework prior to copy
    git checkout ${weekNum}*/02*

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

  # commit if SHOULD_COMMIT
  if [[ $SHOULD_COMMIT -eq 1 ]]; then
    git add ${weekNum}*/02*
    git commit -m "homework $1 solution"
  fi

  #  push if SHOULD_PUSH
  if [[ $SHOULD_PUSH -eq 1 ]] ; then
    git push
  fi
fi