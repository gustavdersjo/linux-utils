#!/bin/false

# Some simple and lightweight utilities that scripts can use.
# No error checking unless otherwise stated.


# --- FUNCTIONS ---

# Echoes with the script name.
# ---
# 1: (str) Message
necho () {
  echo "[$0]: $1"
  return 0
}

# Creates a .bak backup file.
# ---
# 1: (str) File
bak () {
  cp "$1" "$1.bak"
  echo "Backed up \"$1\" to \"$1.bak\"!"
  return 0
}

# Creates a hidden .bak backup file.
# ---
# 1: (str) File
hbak () {
  cp "$1" ".$1.bak"
  echo "Backed up \"$1\" to \".$1.bak\"!"
  return 0
}


# Restores from a hidden .bak backup file.
# ---
# 1: (str) File
ubak () {
  if [[ -f "$1.bak" ]]; then
    cp "$1.bak" "$1"
  elif [[ -f ".$1.bak" ]]; then
    cp ".$1.bak" "$1"
  else
    necho "Did not find any backup of \"$1\"."
    exit 1
  fi
  echo "Restored \"$1\"!"
  return 0
}
