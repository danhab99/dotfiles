# Adjust the PROMPT variable
PROMPT="%(?:%{$fg_bold[green]%}%1{➜%} :%{$fg_bold[red]%}%1{➜%} ) %{$fg[cyan]%}%2~%{$reset_color%}"

# Modify the git_prompt_info function to display the root directory name
git_prompt_info() {
  local ref dirty
  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}$(basename $(git rev-parse --show-toplevel))..%{$fg[red]%}"
    ref=$(git symbolic-ref -q HEAD 2> /dev/null)
    dirty=$(parse_git_dirty)
    if [ -n "$ref" ]; then
      local prompt="%{$reset_color%}${ZSH_THEME_GIT_PROMPT_PREFIX}${ref#refs/heads/}$(parse_git_dirty) %{$fg_bold[blue]%}%1~%{$reset_color%}${ZSH_THEME_GIT_PROMPT_SUFFIX}"
      # Remove the second occurrence of the root directory
      echo "${prompt//\$(basename \$(git rev-parse --show-toplevel))/}"
    else
      echo "%{$fg_bold[blue]%}$(basename $(git rev-parse --git-dir))$(parse_git_dirty) %{$fg_bold[blue]%}%1~%{$reset_color%}${ZSH_THEME_GIT_PROMPT_SUFFIX}"
    fi
  fi
}
PROMPT+=' $(git_prompt_info)'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}%1{✗%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"
