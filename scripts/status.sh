#!/usr/bin/env bash

is_git_team_enabled() {
  local git_team_status=$(git team status 2>&1)
  if [[ "$git_team_status" == *"disabled"* ]]; then
    echo 0
  else
    echo 1
  fi
}


status=$(is_git_team_enabled)
if [[ "$status" -eq 1 ]]; then
  color_fmt="#[fg=#{@thm_green}]#[fg=#11111b,bg=#{@thm_green}]"
  num_co_authors=$(git team status | grep "─" -c)
  status_text="enabled ($num_co_authors co-authors) "
else
  color_fmt="#[fg=#{@thm_red}]#[fg=#11111b,bg=#{@thm_red}]"
  status_text="disabled "
fi

echo "$color_fmt git-team $status_text"
