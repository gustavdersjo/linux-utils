#!/bin/bash

# An utility for deploying unattended processes in screen more easily.

# --- INIT ---
source ${HOME}/util/commons.sh		# Used for logging function.
declare TITLE=""			# The title of the screen.
declare COMMAND=""			# The command to run.
declare ALLOW_MULTIPLE=false		# If we allow multiple instances running at once.
declare ARGUMENT_USAGE=


# --- FUNCTIONS ---
help () {
  necho "USAGE:
[-m|--multiple] ([-t|--title] <TITLE>) ([-c|--cmd|--command] <COMMAND...>)
Note that everything after the --command flag is assumed to be a part of the
command, meaning that all arguments must come before it."
}


# --- Parse named arguments ---

while [[ $# -gt 0 ]]; do
  case "$1" in
    -t|--title)
      TITLE="$2"
      shift  # Shift past argument
      shift  # Shift past value
      ;;
    -m|--multiple)
      ALLOW_MULTIPLE=true
      shift  # Shift past argument
      ;;
    -c|--command|--cmd)
      COMMAND="$2"
      shift  # Shift past argument
      shift  # Shift past value
      break  # Everything after --command is assumed to be a part of the command
      ;;
    -h|--help)
      help
      exit 0  # Help was requested
      ;;
    -*|--*)
      necho "Unknown option \"$1\"."
      help
      exit 1  # Something went wrong
      ;;
    *)
      break  # Everything after here is assumed to be a part of the command
      ;;
  esac
done


# --- Parse unnamed arguments ---

# Set title
if [ "${TITLE}" == "" ]; then
  if [[ $# -lt 1 ]]; then
    necho "Title argument not provided."
    exit 1
  else
    TITLE=$1
    shift  # Shift past value
  fi
fi

# Set command
if [[ $# -lt 1 ]]; then
  necho "Command argument not provided."
  exit 1
else
  while [[ $# -gt 0 ]]; do
    COMMAND+=" $1";
    shift  # Shift past value
  done
fi


# --- Execute ---

necho "Title  : ${TITLE}"
necho "Command: ${COMMAND}"

if ! ${ALLOW_MULTIPLE} && screen -ls | grep -q "${TITLE}"; then
  necho "Screen instance \"${TITLE}\" is already running."
  exit 1
else
  # Note to self: Dont use quotes around screens command argument, IT WILL _NOT_ WORK.
  screen -dmS "${TITLE}" ${COMMAND}
  #sh -c ${COMMAND}
  #screen -S "${TITLE}" ${COMMAND}
  exit 0
fi
