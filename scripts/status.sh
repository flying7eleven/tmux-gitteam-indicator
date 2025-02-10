#!/usr/bin/env bash

# check if the current directory is a git repository
is_git_repository() {
  cd $(tmux display-message -pF "#{pane_current_path}")
  if git rev-parse --is-inside-work-tree 2>&1 | grep -q 'true'; then
    echo 1
  else
    echo 0
  fi
}

# check if git-team is available or not
is_git_team_available() {
  git team > /dev/null 2>&1
  if [[ $? -eq 0 ]] then
    echo 1
  else
    echo 0
  fi
}

# get the configured version of a setting or its default value
get_tmux_option() {
  local option=$1
  local default_value=$2
  local option_value=$(tmux show-option -gqv "$option")
  if [ -z "$option_value" ]; then
    echo "$default_value"
  else
    echo "$option_value"
  fi
}

# check if git team is enabled or not
is_git_team_enabled() {
  local git_team_status=$(git team status 2>&1)
  if [[ "$git_team_status" == *"disabled"* ]]; then
    echo 0
  else
    echo 1
  fi
}

# return the number of co authors in the current repositoy
get_number_of_co_authors() {
  echo $(git team status | grep "─" -c)
}

# define the default values for those settings
gitteam_status_indicator_color_enabled_default="#00ff00"
gitteam_status_indicator_color_disabled_default="#ff0000"
gitteam_status_indicator_icon_default=""
gitteam_status_section_separator_icon_default=" "

# determine if a custom value was set and use it if it is so; otherwise switch to the default
gitteam_status_indicator_color_enabled=$(get_tmux_option "@gitteam_status_indicator_color_enabled" "$gitteam_status_indicator_color_enabled_default")
gitteam_status_indicator_color_disabled=$(get_tmux_option "@gitteam_status_indicator_color_disabled" "$gitteam_status_indicator_color_disabled_default")
gitteam_status_indicator_icon=$(get_tmux_option "@gitteam_status_indicator_icon" "$gitteam_status_indicator_icon_default")
gitteam_status_section_separator_icon=$(get_tmux_option "@gitteam_status_section_separator_icon" "$gitteam_status_section_separator_icon_default")

status=$(is_git_repository)
if [[ "$status" -eq 0 ]]; then
  exit 0
fi

status=$(is_git_team_available)
if [[ "$status" -eq 0 ]]; then
  echo "$color_fmt git-team not available"
  exit 0
fi

status=$(is_git_team_enabled)
if [[ "$status" -eq 1 ]]; then
  color_fmt="#[fg=$gitteam_status_indicator_color_enabled]$gitteam_status_section_separator_icon#[fg=#11111b,bg=$gitteam_status_indicator_color_enabled]$gitteam_status_indicator_icon"
  num_co_authors=$(get_number_of_co_authors)
  if [[ $num_co_authors -eq 1 ]]; then
    status_text="enabled ($num_co_authors co-author) "
  else
    status_text="enabled ($num_co_authors co-authors) "
  fi
else
  color_fmt="#[fg=$gitteam_status_indicator_color_disabled]$gitteam_status_section_separator_icon#[fg=#11111b,bg=$gitteam_status_indicator_color_disabled]$gitteam_status_indicator_icon"
  status_text="disabled "
fi

echo "$color_fmt git-team $status_text"
