local return_code="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"

PROMPT='$(virtualenv_prompt_info)%{[03m%}%{$FG[190]%}%c \
$(git_prompt_info)\
\
%{$fg[red]%}%(!.#.»)%{$reset_color%} '
PROMPT2='%{$fg[red]%}\ %{$reset_color%}'
RPS1='$(vi_mode_prompt_info) %{$FG[165]%}%~%{$reset_color%} ${return_code} '

MODE_INDICATOR="%{$fg_bold[magenta]%}<%{$reset_color%}%{$fg[magenta]%}<<%{$reset_color%}"

ZSH_THEME_GIT_PROMPT_PREFIX="%{$reset_color%}%{$fg[yellow]%}("
ZSH_THEME_GIT_PROMPT_SUFFIX=")%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_CLEAN=""
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}*%{$fg[yellow]%}"
ZSH_THEME_VIRTUAL_ENV_PROMPT_PREFIX="%{$reset_color%}%{[03m%}%{$fg[blue]%}"
ZSH_THEME_VIRTUAL_ENV_PROMPT_SUFFIX="!%{$reset_color%} "
