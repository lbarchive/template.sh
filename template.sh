#!/bin/bash
# !!! PLEASE READ !!!
# This Bash script template IS NOT licensed under the MIT License, but place in
# the Public Domain. The MIT License text is included because I 99% license my
# work with it.
#
# Things You Need to Change:
#   1. <NAME> and <DESCRIPTION> - script name and description
#   2. <YEAR> and <NAME>
#   3. Edit usage(), parse_options()
#   4. Write code in main section
#   5. Remove PLEASE READ section and anything you don't want
#
# This Bash script template is made by Yu-Jie Lin.
# !!!     END     !!!
# <NAME> - <DESCRIPTION>
# Copyright (c) <YEAR> <NAME>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
# of the Software, and to permit persons to whom the Software is furnished to do
# so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

#############
# Settinigs #
#############

# Max number of arguments, empty vaule = unlimited arguments
SCRIPT_MAX_ARGS=0

#########################
# Common Initialization #
#########################

SCRIPT_NAME="$(basename "$0")"
# Stores arguments
SCRIPT_ARGS=()
# Stores option flags
SCRIPT_OPTS=()
# For returning value after calling SCRIPT_OPT
SCRIPT_OPT_VALUE=

#############
# Functions #
#############

usage () {
  echo "Usage: $SCRIPT_NAME [options] [arguments]

Options:
  --no-color   do not use colors
  -h, --help   display this help and exit
"  
}

# XXX this can be rewritten with an options array, e.g.
# (
#   '-o|--option-with-arg'    'help_message' 'OPTION_FLAG'  'option1_handler_function' ...
#   '-O|--option-without-arg' 'help_message' 'OPTION_FLAG1' 'option2_handler_function' ...
#   ...
# )
# And this way can automatically have help message, etc...
# However this might become a full-set library
parse_options() {
  while (( $#>0 )); do
    opt="$1"
    arg="$2"
    
    case "$opt" in
      -o|--option-with-arg)
        SCRIPT_OPT_SET "opt1" "$arg" 1
        shift
        ;;
      -O|--option-without-arg)
        SCRIPT_OPT_SET "opt2"
        ;;
      -e|--option-needs-do-something-right-away)
        do_something
        ;;
      --no-color)
        SCRIPT_OPT_SET "no-color"
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      -*)
        echo "$SCRIPT_NAME: invalid option -- '$opt'" >&2
        echo "Try \`$SCRIPT_NAME --help' for more information." >&2
        exit 1
        ;;
      *)
        if [[ ! -z $SCRIPT_MAX_ARGS ]] && (( ${#SCRIPT_ARGS[@]} == $SCRIPT_MAX_ARGS )); then
          echo "$SCRIPT_NAME: cannot accept any more arguments -- '$opt'" >&2
          echo "Try \`$SCRIPT_NAME --help' for more information." >&2
          exit 1
        else
          SCRIPT_ARGS=("${SCRIPT_ARGS[@]}" "$opt")
        fi
        ;;
    esac
    shift
  done
}

###########################
# Script Template Functions

# Stores options
# $1 - option name
# $2 - option value
# $3 - non-empty if value is not optional
SCRIPT_OPT_SET () {
  if [[ ! -z "$3" ]] && [[ -z "$2" ]]; then
    echo "$SCRIPT_NAME: missing option value -- '$opt'" >&2
    echo "Try \`$SCRIPT_NAME --help' for more information." >&2
    exit 1
  fi
  # XXX should check duplication, but doesn't really matter
  SCRIPT_OPTS=("${SCRIPT_OPTS[@]}" "$1" "$2")
}

# Checks if an option is set, also set SCRIPT_OPT_VALUE.
# Returns 0 if found, 1 otherwise.
SCRIPT_OPT () {
  local i opt needle="$1"
  for (( i=0; i<${#SCRIPT_OPTS[@]}; i+=2 )); do
    opt="${SCRIPT_OPTS[i]}"
    if [[ "$opt" == "$needle" ]]; then
      SCRIPT_OPT_VALUE="${SCRIPT_OPTS[i+1]}"
      return 0
    fi
  done
  SCRIPT_OPT_VALUE=
  return 1
}

SCRIPT_SET_COLOR_VARS () {
  local COLORS=(BLK RED GRN YLW BLU MAG CYN WHT)
  local i SGRS=(RST BLD ___ ITA ___ BLK ___ INV)
  for (( i=0; i<8; i++ )); do
    eval "F${COLORS[i]}=\"\e[3${i}m\""
    eval "B${COLORS[i]}=\"\e[4${i}m\""
    eval   "T${SGRS[i]}=\"\e[${i}m\""
  done
}

########
# Main #
########

parse_options "$@"

if ! SCRIPT_OPT "no-color"; then
  SCRIPT_SET_COLOR_VARS
fi

# start to do something

if SCRIPT_OPT "opt1"; then
  echo -e "opt1 is set: ${FBLU}${TBLD}${SCRIPT_OPT_VALUE}${TRST}"
else
  echo "opt1 is not set"
fi
