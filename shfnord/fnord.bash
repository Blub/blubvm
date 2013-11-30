#!/usr/bin/bash
# vim: ts=2 sts=2 sw=2 et:

all_fnord=../all_fnord.cfg

# Read the databases
while read word_type; do
  while read entry; do
    eval "db_${word_type}=(\"\${db_${word_type}[@]}\" \"${entry}\")"
  done < <(sed -n "/^fnord_load $word_type/,/^fnord_save $word_type/{
      /dbpush/{
        s/dbpush[^\"]*\"//;
        s/\"$//;
        p
      }
    }" "${all_fnord}")
done < <(grep fnord_load "$all_fnord" | awk '{print $2}')

spc=''

chance() {
  local pc=$1; shift
  if (( (RANDOM % 100) >= pc )); then
    "$@"
  fi
}

fnord() {
  for db in "$@"; do
    eval "local count=\${#db_${db}}"
    local idx=$((RANDOM % count))
    eval "printf '%s%s' \"$spc\" \"\${db_${db}[$idx]}\""
    spc=' '
  done
}

in_place() {
  printf '%sin' "$spc"
  spc=' '
  fnord places
}

finish() {
  echo .
}

fnord_rule0() {
  spc=' '
  printf 'The'
  chance 50 fnord adjectives
  fnord nouns
  chance 20 in_place
  printf ' is'
  fnord adjectives
}

fnord_rule1() {
  fnord names actions
  printf ' the'
  fnord adjectives nouns
  printf ' and the'
  fnord adjectives nouns
}

fnord_rule2() {
  spc=' '
  printf 'The'
  fnord nouns
  printf ' from'
  fnord places
  printf ' will go to'
  fnord places
}

fnord_rule3() {
  fnord names
  printf ' must take the'
  fnord adjectives nouns
  printf ' from'
  fnord places
}

fnord_rule4() {
  fnord places
  printf ' is'
  fnord adjectives
  printf ' and the'
  fnord nouns
  printf ' is'
  fnord adjectives
}

fnord_rule5() {
  fnord names prepositions places
  printf ' for the'
  fnord adjectives nouns
}

fnord_rule6() {
  spc=' '
  printf 'The'
  chance 50 fnord adjectives
  fnord nouns actions
  printf ' the'
  fnord adjectives nouns
  chance 20 in_place
}

fnord_rule7() {
  fnord names prepositions places
  printf ' and'
  fnord actions
  printf ' the'
  fnord nouns
}

fnord_rule8() {
  fnord names
  printf ' takes'
  fnord pronouns
  chance 50 fnord adjectives
  fnord nouns
  printf ' and'
  fnord prepositions places
}

fnord_rule9() {
  fnord names actions
  printf ' the'
  chance 50 fnord adjectives
  fnord nouns
}

fnord_rule10() {
  fnord names actions names
  printf ' and'
  fnord pronouns
  chance 50 fnord adjectives
  fnord nouns
}

fnord_rule11() {
  spc=' '
  printf 'You must meet'
  fnord names
  printf ' at'
  fnord places
  printf ' and get the'
  chance 50 fnord adjectives
  fnord nouns
}

fnord_rule12() {
  spc=' '
  printf 'A'
  fnord nouns
  printf ' from'
  fnord places actions
  printf ' the'
  chance 50 fnord adjectives
  chance 20 fnord adjectives
  fnord nouns
}

capitalize() {
  # I can't believe those 2 commands are of similar length...
  #sed -e 'h;s/^\(.\).*$/\1/;y/a-z/A-Z/;G;s/^\(.\)../\1/'
  awk '{ print toupper(substr($1,1,1)) substr($0,2) }'
  # The perl-line-noiseaddicted part of my brain wanted to do the first version
  # I wonder if the shell has a variable-substitution mechanism that equals the behavior
  # or 'tr'...
  # This one's the worst:
  #read line
  #printf '%s%s\n' "$(echo ${line:0:1} | tr 'a-z' 'A-Z')" "${line:1}"
}

{
  eval "fnord_rule$((RANDOM%13))"
  finish
} | capitalize
