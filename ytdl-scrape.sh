#!/bin/bash

# An utility for downloading videos or audio with youtube-dl more easily.


# --- INIT ---

# -- Source some common functions --
source commons.sh

# -- Declare variables --
# The URL to download from.
declare URL=""
# The output folder/file.
declare OUTPUT=""
# Any arguments to give to the external downloader.
declare DOWNLOADER_ARGS="--max-concurrent-downloads=32 --max-connection-per-server=16 --split=8 --min-split-size=1M --continue=true"
# If we should use caching. Prevents redownloads of already present files.
declare CACHE=""
# If we should extract audio (and discard video).
declare EXTRACT_AUDIO=""
# Any kwargs for youtube-dl
declare KWARGS=""


# --- PARSE ARGS ---

while [[ $# -gt 0 ]]; do
  case $1 in
    -u|--url)
      URL="$2"
      shift # past argument
      shift # past value
      ;;
    -o|--output)
      OUTPUT="$2"
      shift # past argument
      shift # past value
      ;;
    --downloader-args)
      DOWNLOADER_ARGS=$2
      shift # past argument
      shift # past value
      ;;
    -c|--cache)
      CACHE="--download-archive ${OUTPUT}/downloaded.txt"
      shift # past argument
      ;;
    -e|--extract-audio)
      EXTRACT_AUDIO="--extract-audio"
      shift # past argument
      ;;
    -*|--*)
      necho "${SCRIPT_NAME}: Unknown option \"$1\"."
      exit 1
      ;;
    *)
      break
      ;;
  esac
done


# --- Parse unnamed arguments ---

# Set URL
if [ "${URL}" == "" ]; then
  if [[ $# -lt 1 ]]; then
    necho "URL argument not provided."
    exit 1
  else
    URL=$1
    shift  # Shift past value
  fi
fi

# Set output
if [ "${OUTPUT}" == "" ]; then
  if [[ $# -lt 1 ]]; then
    necho "Output argument not provided."
    exit 1
  else
    OUTPUT=$1
    shift  # Shift past value
  fi
fi

# Set kwargs
while [[ $# -gt 0 ]]; do
  KWARGS+="$1 ";
  shift  # Shift past value
done


# --- EXECUTE ---

necho "URL   : \"${URL}\""
necho "OUTPUT: \"${OUTPUT}\""

youtube-dl \
	--ignore-errors --no-check-certificate \
	--format "bestvideo+bestaudio/best" ${EXTRACT_AUDIO} \
	--yes-playlist \
	--embed-thumbnail --add-metadata \
	--write-sub  --sub-format best --sub-lang en \
	--output ${OUTPUT}/"%(title)s.%(ext)s" ${CACHE} \
	--external-downloader aria2c \
	--external-downloader-args "${DOWNLOADER_ARGS}" \
	${KWARGS} ${URL}
