# dokov.zsh-theme
# inspired by https://github.com/ohmyzsh/ohmyzsh/blob/master/themes/af-magic.zsh-theme
# Repo: https://github.com/ivandokov/dotfiles/tree/master/zsh/custom/themes

typeset +H c_aqua="$FG[006]"
typeset +H c_blue="$FG[075]"
typeset +H c_green="$FG[078]"
typeset +H c_lime="$FG[046]"
typeset +H c_purple="$FG[201]"
typeset +H c_yellow="$FG[184]"

PS1='$c_aqua %~$(git_prompt_info) $c_lime%(!.#.›)%{$reset_color%} '

ZSH_THEME_GIT_PROMPT_PREFIX=" $c_yellow"
ZSH_THEME_GIT_PROMPT_CLEAN=""
ZSH_THEME_GIT_PROMPT_DIRTY="$c_purple·%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="$c_yellow%{$reset_color%}"
