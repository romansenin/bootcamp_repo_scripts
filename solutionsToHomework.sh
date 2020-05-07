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
  pathToContent="/Users/rasenin/Desktop/ucd-boot-camp/gitlab/December/fullstack-ground/01-Class-Content"
  pathToStudentRepo="/Users/rasenin/Desktop/ucd-boot-camp/gitlab/December/UCD-SAC-FSF-PT-12-2019-U-C"

  weekNum=$(reFormatNum $1)

  if [[ -n "$(ls ${pathToContent}/${weekNum}*/02*/Master 2>/dev/null)" ]]; then
    cp -r ${pathToContent}/${weekNum}*/02*/Master ${pathToStudentRepo}/${weekNum}*/02*

    source=$(echo ${pathToContent}/${weekNum}*/02*/Master | sed -E 's/.*01-Class-Content\/(.*)/\1/')
    destination=$(echo ${pathToStudentRepo}/${weekNum}*/02* | sed -E 's/^.*(UCD.*)/\1/')

    barLength=$((${#source} + ${#destination} + 4))

    printf '%.0s-' $(seq 1 $barLength)
    printf '\n'
    printf "$source -> $destination"
    printf '\n'
    printf '%.0s-' $(seq 1 $barLength)
    printf '\n\n'
  else
    week=$(echo ${pathToContent}/${weekNum}*/02* | sed -E 's/.*01-Class-Content\/(.*)/\1/')
    tail="/Master Not Found"
    barLength=$((${#week} + ${#tail}))

    printf '%.0s-' $(seq 1 $barLength)
    printf '\n'
    echo "${week}${tail}"
    printf '%.0s-' $(seq 1 $barLength)
    printf '\n\n'
  fi 
fi