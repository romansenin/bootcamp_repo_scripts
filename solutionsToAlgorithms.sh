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
  echo "[Week Number]         week number for the desired new algorithms in the source repo"
  echo "[Start Algorithm]     starting algorithm to copy"
  echo "[End Algorithm]       ending algorithm to copy (inclusive)"
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

if [[ "$#" -ne 3 ]]; then
  echo "Usage: ./solutionsToAlgorithms.sh [options] [Week Number] [Start Algorithm] [End Algorithm]. Type -h or --help for more information."
else
  # load path vars $pathtoContent and $pathToStudentRepo
  DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
  source "${DIR}/.env"

  cd $pathToStudentRepo

  weekNum=$(reFormatNum $1)

  for num in $(seq $2 $3); do
    algorithmNum=$(reFormatNum $num)

    if [[ -n "$(ls ${pathToContent}/01*/${weekNum}*/03*/${algorithmNum}*/Solved 2>/dev/null)" ]]; then
      # undo any changes in algorithm prior to copy
      git checkout ${weekNum}*/03*/${algorithmNum}*

      cp -r ${pathToContent}/01*/${weekNum}*/03*/${algorithmNum}*/Solved ${pathToStudentRepo}/${weekNum}*/03*/${algorithmNum}*

      # git add algorithm
      if [[ $SHOULD_COMMIT -eq 1 ]] ; then 
        git add ${weekNum}*/03*/${algorithmNum}*
      fi

      source=$(echo ${pathToContent}/01*/${weekNum}*/03*/${algorithmNum}*/Solved | sed -E 's/.*Algorithms\/([0-9]+.*)/\1/')
      destination=$(echo ${pathToStudentRepo}/${weekNum}*/03*/${algorithmNum}* | sed -E 's/^.*(UCD.*)/\1/')

      barLength=$((${#source} + ${#destination} + 4))

      printf '%.0s-' $(seq 1 $barLength)
      printf '\n'
      printf "$source -> $destination"
      printf '\n'
      printf '%.0s-' $(seq 1 $barLength)
      printf '\n\n'
    else
      algorithm=$(echo ${pathToContent}/01*/${weekNum}*/03*/${algorithmNum}* | sed -E 's/.*Algorithms\/([0-9]+.*)/\1/')
      tail="/Solved Not Found"
      barLength=$((${#algorithm} + ${#tail}))

      printf '%.0s-' $(seq 1 $barLength)
      printf '\n'
      echo "${algorithm}${tail}"
      printf '%.0s-' $(seq 1 $barLength)
      printf '\n\n'
    fi 
  done

  # commit if SHOULD_COMMIT
  if [[ $SHOULD_COMMIT -eq 1 ]]; then 
    git commit -m "algorithm solutions"
  fi
  
  #  push if SHOULD_PUSH
  if [[ $SHOULD_PUSH -eq 1 ]] ; then
    git push
  fi
fi