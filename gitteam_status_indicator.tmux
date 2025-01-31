#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

main() {
  tmux set -g @gitteam_status_indicator "#($CURRENT_DIR/scripts/status.sh)"
}

main
