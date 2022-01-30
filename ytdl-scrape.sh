#!/bin/bash

# An utility for downloading videos or audio with youtube-dl more easily.

# --- INIT ---

source commons.sh
declare URL=""						# The URL to download from.
declare OUTPUT=""					# The output folder/file.
declare DOWNLOADER_ARGS="-c -j 32 -x 16 -s 8 -k 1M"	# Any arguments to give to the external downloader.
declare CACHE=""					# If we should use caching. Prevents redownloads of already present files.
declare EXTRACT_AUDIO=""				# If we should extract audio (and discard video).
declare KWARGS=""					# Any kwargs for youtube-dl


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
	--external-downloader-args "\"${DOWNLOADER_ARGS}\"" \
	${KWARGS} ${URL}

	# Don't stop on errors. Keep downloading the entire playlist.
	# Use the best format.
	#--audio-format mp3 \
	# Allow playlists.
	# Embed thumbnail and metadata.
	# Embed subtitles.
	# Output and cache settings.
	# Use aria2c for faster downloading.
	# Arguments for aria2c.
	# The URL to download.
	# Any kwargs for youtube-dl.


# Notes on the aria2c arguments used:
#
# -c, --continue [true|false]
#   Continue downloading a partially downloaded file.
#
# -j, --max-concurrent-downloads=<N>
#   Set the maximum number of parallel downloads for every queue item.
#   See also the --split option.
#   Default: 5
#
# -x, --max-connection-per-server=<NUM>
#   The  maximum  number  of connections to one server for each download.
#
# -s --split=<N>
#   Download a file using N connections. If more than N URIs are given, first N
#   URIs are used and remaining URIs are used for backup. If less than N URIs
#   are given, those URIs are used more than once so that N connections total
#   are made simultaneously. The number of connections to the same host is
#   restricted by the --max-connection-per-server option.
#   See also the --min-split-size option.
#   Default: 5
#
#
# -k, --min-split-size=<SIZE>
#   aria2 does not split less than 2*SIZE byte range. For example, let's
#   consider downloading 20MiB file. If SIZE is 10M, aria2 can split file into
#   two range [0-10MiB) and [10MiB-20MiB) and download it using two
#   sources(if--split >= 2, of course). If SIZE is 15M, since 2*15M > 20MiB,
#   aria2 does not split the file and downloads it using one source.
#   You can append K or M (1K = 1024, 1M = 1024K).
#   Possible Values: 1M - 1024M
#   Default: 20M
#
# Source: aria2c manpage
