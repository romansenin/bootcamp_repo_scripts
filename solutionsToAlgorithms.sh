function reFormatNum() {
  argLength=${#1}

  if [[ argLength -eq 1 ]]; then
    echo "0${1}"
  else
    echo $1
  fi
}

if [[ "$#" -ne 3 ]]; then
  echo "Usage: ./solutionsToAlgorithms.sh [Week Number] [Start Algorithm] [End Algorithm]"
else
  pathToContent="/Users/rasenin/Desktop/ucd-boot-camp/gitlab/December/fullstack-ground/01-Class-Content"
  pathToStudentRepo="/Users/rasenin/Desktop/ucd-boot-camp/gitlab/December/UCD-SAC-FSF-PT-12-2019-U-C"

  weekNum=$(reFormatNum $1)

  for num in $(seq $2 $3); do
    algorithmNum=$(reFormatNum $num)

    if [[ -n "$(ls ${pathToContent}/${weekNum}*/03*/${algorithmNum}*/Solved 2>/dev/null)" ]]; then
      cp -r ${pathToContent}/${weekNum}*/03*/${algorithmNum}*/Solved ${pathToStudentRepo}/${weekNum}*/03*/${algorithmNum}*
      pathToSolved=$(cd ${pathToContent}/${weekNum}*/03*/${algorithmNum}*/Solved; pwd)

      source=$(echo ${pathToContent}/${weekNum}*/03*/${algorithmNum}*/Solved | sed -E 's/.*Algorithms\/([0-9]+.*)/\1/')
      destination=$(echo ${pathToStudentRepo}/${weekNum}*/03*/${algorithmNum}* | sed -E 's/^.*(UCD.*)/\1/')

      barLength=$((${#source} + ${#destination} + 4))

      printf '%.0s-' $(seq 1 $barLength)
      printf '\n'
      printf "$source -> $destination"
      printf '\n'
      printf '%.0s-' $(seq 1 $barLength)
      printf '\n\n'
    else
      algorithm=$(echo ${pathToContent}/${weekNum}*/03*/${algorithmNum}* | sed -E 's/.*Algorithms\/([0-9]+.*)/\1/')
      tail="/Solved Not Found"
      barLength=$((${#algorithm} + ${#tail}))

      printf '%.0s-' $(seq 1 $barLength)
      printf '\n'
      echo "${algorithm}${tail}"
      printf '%.0s-' $(seq 1 $barLength)
      printf '\n\n'
    fi 
  done
fi