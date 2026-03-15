#!/bin/bash
scriptfile=$(realpath "$0")
workdir="$(dirname "$scriptfile")"

cd "$workdir"
./ssh-remote-forward-22.sh "35.234.23.44" 443 6000
