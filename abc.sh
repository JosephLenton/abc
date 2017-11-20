
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
__ABCS__PROGRAMMING_EXTENSIONS__="
  sh
  sql

  rs

  h
  c cpp

  cs
  java jsp
  scala

  php
  pl perl py

  vbs vba vb

  tcl

  js jsx
  ts tsx
  coffee

  vue

  vim

  json
  xml
  yml yaml
  toml

  html  htm  hta
  xhtml xhtm
  css less styl sass

  m
  txt md markdown

  csv
  tf
"

# Remove excessive spaces and end of line.
# All extensions seperated by a single space.
__ABCS__PROGRAMMING_EXTENSIONS__=`sed -E -e ':a;N;$!ba;s/[ \n\r]+/ /g' -e 's/(^ )//' <<< $__ABCS__PROGRAMMING_EXTENSIONS__`

# 
#   java -> /^.*\.java$/
# 
__ABCS__PROGRAMMING_EXTENSIONS__EDIT_AWK__="/^.*\\.${__ABCS__PROGRAMMING_EXTENSIONS__// /$/\ || /^.*\\.}$/"

# 
#   java -> /^.*\.java$/
# 
__ABCS__PROGRAMMING_EXTENSIONS__FIND__="-type f -name \"*.${__ABCS__PROGRAMMING_EXTENSIONS__// /\" -o -type f -name \"*.}\""

# 
#   java -> **/*.java
# 
__ABCS__PROGRAMMING_EXTENSIONS__GREP__="**/*.${__ABCS__PROGRAMMING_EXTENSIONS__// / **/*.}"

# 
# Colours used for output.
# 
__ABCS__PROGRAMMING_EXTENSIONS__DIR_COL__="\x1b[38;2;230;115;10m"
__ABCS__PROGRAMMING_EXTENSIONS__DIR_HIDDEN_COL__="\x1b[38;2;140;85;24m"
__ABCS__PROGRAMMING_EXTENSIONS__FILE_COL__="\x1b[38;2;60;230;60m"
__ABCS__PROGRAMMING_EXTENSIONS__FILE_HIDDEN_COL__="\x1b[38;2;30;150;30m"
__ABCS__PROGRAMMING_EXTENSIONS__NO_COL__="\x1b[0m"


# 
# c for cd, change the directory.
# 
function c() {
  local path=$1; shift

  local result=$?
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
  local search=$1
  local dir=.

  # 
  # We're given an exact file name.
  # So just edit it.
  # 
  if [ -f "$search" ]; then
    v "$search"
    return 0
  fi

  # 
  # Check for a slash.
  # 
  # We adjust the directory we are searching
  # and grab out just the basename.
  # 
  if [[ "$search" == *\/* ]] || [[ "$search" == *\\* ]]; then
    search=$(basename "$search")
    dir=$(dirname "$search")
  fi

  # Fail, empty search given.
  if [[ "$search" = '' ]]; then
    echo '    no file given'
    return 1
  fi

  local name="iname"
  local hasUpperCase=`grep "[[:upper:]]" <<< "$search"`
  if [[ $hasUpperCase ]]; then
    name="name"
  fi

  # Search for the file.
  find "$dir" -type f \( -path .git -o -path .github \) -prune -o -$name "*$search*" | awk "$__ABCS__PROGRAMMING_EXTENSIONS__EDIT_AWK__" > ~/.temp/e
  local numLines=`wc --line ~/.temp/e | sed -E 's/(^ *)|( .*$)//g'`

  # Fail, no files found.
  if [[ $numLines -eq '0' ]]; then
    echo '    no files found'
    return 1
  fi

  # Success, one file found.
  if [[ $numLines -eq '1' ]]; then
    v `cat ~/.temp/e`
    return 0
  fi

  # Fail, too many files found.
  # First, lets check if the name given matches an exact file in the files found.
  local searchEscaped=$(__abcs__regex_escape__ $search)
  grep -E -- "(^|/)$searchEscaped$" ~/.temp/e > ~/.temp/e2
  numLines=`wc --line ~/.temp/e2 | sed -E 's/(^ *)|( .*$)//g'`

  # Success, one file found.
  if [[ $numLines -eq '1' ]]; then
    v `cat ~/.temp/e2`
    return 0
  fi

  # Second, we look for a file that matches regardless of extension.
  local searchEscaped="$searchEscaped.[^.]+"
  grep -E -- "(^|/)$searchEscaped$" ~/.temp/e > ~/.temp/e2
  numLines=`wc --line ~/.temp/e2 | sed -E 's/(^ *)|( .*$)//g'`

  # Success, one file found.
  if [[ $numLines -eq '1' ]]; then
    v `cat ~/.temp/e2`
    return 0
  fi

  # Fail, too many files found.
  cat ~/.temp/e
  return 1
}

# 
# f for find, find a file with some of the name given.
# 
function f() {
  find . -iname "*$@*" -type f
}

# 
# n for now, get the current time.
#
function n() {
  date +%R
}

# 
# r for replace in files.
# 
#     r search-term replacement
# 
# Warning! This works in place in files as standard.
# 
function r() {
  local search=`__abcs__regex_escape__ $1`
  local replace=`__abcs__slash_escape__ $2`
  local files=`__abcs__list_files_single_line__`

  eval "sed -i 's/$search/$replace/g' $files"
}

# 
# s for search, search in files with grep using literal text.
# 
function s() {
  __abcs__grep__ -F "$*"
}

# 
# sr for search regex, search in files with grep using a regex.
# 
function sr() {
  __abcs__grep__ -E "$*"
}

function __abcs__grep__() {
  local matchArg=$1
  local searchString=$2
  local grepArgs=""
  local hasUpperCase=`grep "[[:upper:]]" <<< "$searchString"`

  if [[ $hasUpperCase ]]; then
    grepArgs="-sn"
  else
    grepArgs="-sni"
  fi

  eval "grep $matchArg $grepArgs -- \"$searchString\" $__ABCS__PROGRAMMING_EXTENSIONS__GREP__"
}

# 
# This will list out all the found extension files we have.
# 
# This will print it out with all files on 1 line.
# As filenames can contain a space, they will be escaped.
# 
function __abcs__list_files_single_line__() {
  __abcs__list_files_multi_line__ $* | sed -e 's/ /\\ /' | tr '\n' ' '
}

# 
# This will list out all the found extension files we have.
# 
# This will print it out with 1 file per line.
# 
function __abcs__list_files_multi_line__() {
  eval "find . $__ABCS__PROGRAMMING_EXTENSIONS__FIND__"
}

function __abcs__slash_escape__() {
  echo "${@//\//\\/}"
}

function __abcs__regex_escape__() {
  sed 's/[^^]/[&]/g; s/\^/\\^/g' <<< "$@"
}

