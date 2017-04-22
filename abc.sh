
# 
# ABCs
# 
# One letter commands for day to day development.
# 

# 
# Programming Extensions.
# 
# These are used for all commands which will find files for you.
# 
# We consider these the files we are interested in day to day.
# Namely programming files and document formats.
# i.e. Stuff we want to grep, want to edit, and so on.
# 
__ABC_PROGRAMMING_EXTENSIONS__="
  h
  c cpp
  cs
  java jsp
  scala
  php
  pl perl py
  vbs vba vb
  js jsx
  ts tsx
  coffee
  json
  xml
  yml yaml
  html  htm  hta
  xhtml xhtm
  m
  css less styl sass
  txt md markdown
  sql
  csv
  tf
"

# Remove excessive spaces and end of line.
# All extensions seperated by a single space.
__ABC_PROGRAMMING_EXTENSIONS__=$(
    echo "$__ABC_PROGRAMMING_EXTENSIONS__" | sed -E ':a;N;$!ba;s/[ \n\r]+/ /g'
)

# 
#   java -> /^.*\.java$/
# 
__ABC_PROGRAMMING_EXTENSIONS__EDIT_AWK__="/^.*\\.${__ABC_PROGRAMMING_EXTENSIONS__// /$/\ || /^.*\\.}$/"

# 
#   java -> **/*.java
# 
__ABC_PROGRAMMING_EXTENSIONS__GREP__="**/*.${__ABC_PROGRAMMING_EXTENSIONS__// / **/*.}"

# 
# c for cd, change the directory.
# 
function c() {
  path=$1
  shift

  result=$?
  if [ $result -ne 0 ]; then
    pushd $path
    exit
  fi

  for i in "$@"; do
    path="$path/$i"
  done

  pushd "$path" > /dev/null
  l
}

# 
# e for edit, search for a matching file and edit it.
# 
#  - When no files are found          -> print an error
#  - When more than one file is found -> list them
#  - When just one file is found      -> edit it!
# 
function e() {
  search=$1
  dir=.

  # 
  # We're given an exact file name.
  # So just edit it.
  # 
  if [ -f "$search" ]; then
    gvim "$search"
    return 0
  fi

  # 
  # Check for a slash.
  # 
  # We adjust the directory we are searching
  # and grab out just the basename.
  # 
  if [[ "$search" == *\/* ]] || [[ "$search" == *\\* ]]; then
    dir=$(dirname "$search")
    search=$(basename "$search")
  fi

  # Fail, empty search given.
  if [[ "$search" = '' ]]; then
    echo '    no file given'
    return 1
  fi

  # Search for the file.
  find "$dir" -name "*$search*" -type f | awk "$__ABC_PROGRAMMING_EXTENSIONS__EDIT_AWK__" > ~/.temp/e
  numLines=`wc --line ~/.temp/e | sed -E 's/(^ *)|( .*$)//g'`

  # Fail, no files found.
  if [[ $numLines -eq '0' ]]; then
    echo '    no files found'
    return 1

  # Success, one file found.
  elif [[ $numLines -eq '1' ]]; then
    gvim `cat ~/.temp/e`

  # Fail, too many files found.
  else
    cat ~/.temp/e

  fi
}

# 
# f for find, find a file with some of the name given.
# 
function f() {
  find . -name "*$**" -type f
}

# 
# n for now, get the current time.
#
function n() {
  date +%R
}

# 
# l for ls, but prettier.
#
function l() {
  path=${1:-.}

  DIR_COL="\e[1;34m"
  DIR_COL="\e[38;2;210;115;7m"
  NO_COL="\e[0m"

  fs=~/.temp/l
  fs2=~/.temp/l2

  > $fs
  > $fs2

  #ls -1ad -- $path 2> /dev/null | sed 's/\///' > $fs
  find "$path" -maxdepth 1 -type d -name "*" 2> /dev/null | \
    sed \
      -e 's/^.*\///' \
      -e '/^\.$/d'   \
      -e '/^[ \n\r\t]*$/d' \
      > $fs

  while read -r line
  do
    echo -e "$DIR_COL$line$NO_COL" >> $fs2
  done < $fs

  fswidth=$(( $(wc -L <"$fs2") + 4 ))

  echo ''
  paste "$fs2" <(ls -pa | grep -v /)                                          \
    | expand -t $fswidth                                                      \
    | sed                                                                     \
      -e 's/^/    /'                                                          \
      -e 's/^            //'                                                  \
      -e '1 s/^[^ ]/        &/'                                               \
      -e 's/^        [^ ]/        &/'
}

# 
# s for search, search in files with grep using literal text.
# 
function s() {
  __abcs__grep__ -F "$*"
}

# 
# r for regex, search in files with grep using a regex.
# 
function r() {
  __abcs__grep__ -E "$*"
}

function __abcs__grep__() {
  matchArg=$1
  searchString=$2

  hasUpperCase=`grep "[[:upper:]]" <<< "$searchString"`
  if [[ $hasUpperCase ]]; then
    grepArgs="-sn"
  else
    grepArgs="-sni"
  fi

  eval "grep $matchArg $grepArgs \"$searchString\" $__ABC_PROGRAMMING_EXTENSIONS__GREP__"
}

