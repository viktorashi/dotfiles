##############
# ALIASES ####
##############

### toate sa tinam inte configu

config_worktree_folder="$HOME"
git_dir="${config_worktree_folder}/.cfg/"
alias configotofolder="cd ${config_worktree_folder}"
alias config="git --git-dir=${git_dir} --work-tree=${config_worktree_folder}"
alias configst="config status"
alias configadd="config add ${config_worktree_folder}/.config/nvim && config status"
alias conf="configadd"
alias configlazygit="lazygit --git-dir=${config_worktree_folder}/.cfg/ --work-tree=${config_worktree_folder}"

alias cls='clear'
alias clc='clear'
alias cl='clear'
alias ..='cd ..'
alias ...='cd ../../'
alias l='ls'
#i always mess this up so ye
alias sc='source ~/.bashrc'
alias gr='egrep -irna'
#ai numa grija dupa n-o sa-ti mai mearga ghostcript daca ai nevoie de el, da nu afecteaza ce chestii foloesti TeX si asa, nu cred
#pot sa fac asta sau sa dau la unele
#	git config --global alias.<alias-name> "<aliased-git-subcommand>"
#	da problema e ca dupa nu mai poti sa faci daor "gs" tre sa faci "git s" sau "git gs" or smth
#
alias gs='git status'
alias gp='git push'
alias gc='git commit -a && gp'
alias gpul='git pull'
alias gd='git diff'
alias ga='git add .'
alias gl='git log --graph --pretty'
alias grso='git remote show origin'
#BAI sa faci asta numa daca n-ai dat inca pushh baa ca e bataie de cap dupa
alias gca='git commit -a --amend'
alias gf='git fetch'
alias gch='git checkout'
alias gb='git branch -a'
#hehe acuma nu prea o sa mai folosestsca asat de cand cu git worktree
#foloseste sa dai stash cu un nume sa stii ce are stashul in el (pui "mesaj" dupa)
alias gsp='git stash push -m' #<mesaj> dupa
alias gsl='git stash list'

#pe astea de jos le-am pus cum leam pus fiindca stash pop == apply && drop, si dupa daca ii dai drop e prea tarziu daca ai vreun conflict si ai facut vreo prostie
alias gsa='git stash apply' #mai intai asta ca e mai safe decat pop
alias gsd='git stash drop'  #asta face practic pop

alias gw='git worktree'

alias grp='git remote prune origin'
alias ghm='gh pr merge --admin -d && grp'
#sunt prea putoare
#alias m='make'
alias dp='docker ps -a'
#alias ds='docker start'

#amandoua astea bune la rescuenow
#alias dr='deno task run'
#alias fpg='flutter pub get'

alias di='docker image'
alias dil='docker image list'
alias dcu='docker compose up'
alias dcd='docker compose down'
#alias py='python3'
alias python='python3'
alias pip='pip3'
alias ls='ls -a'
alias ll='ls -l'
#FRFRFF fr for reals
alias fr='flask run' # dupa pui --app <numele la ce package ii zice la aplicatie> run
#laternativa mai era
#alias fr='flutter run'
#acm de cand cu zoxide nu prea mai e nevoie lmao
#alias licenta='cd ~/Documents/toate-de-la-faculta-trecut/licenta/texuri/bachelor-thesis-repo/bachelor-thesis'

alias iv='fzf -m --preview="bat --color=always {}" --bind "enter:become(nvim {+})"'

##############
#de editoare##

alias nv='nvim'
alias proiect='cd /d/SHWARMA/stimulator'
alias rustbook='cd /c/Users/istan/random-tec/rust-book'

##############
#deschide pycharm in curr_dirkoilk;
# alias charm='open -na "PyCharm Professional Edition.app" .'
# alias char='open -na "PyCharm Professional Edition.app" .'
# alias cha='open -na "PyCharm Professional Edition.app" .'
# alias ch='open -na "PyCharm Professional Edition.app" .'
alias o='explorer .'

alias c='code .'
alias idea='idea .'
#sa dea follow la redirecturi
alias curl='curl -L'
#vezi ce programe folosesc un anumit port
alias findport='sudo lsof -i '
#cam mereu vreau doar sa se opreasca direct cand il gaseste
alias ping='ping -o'
#sa vezi ma merge netu
alias pg='ping google.com'

#sa faci checksumuri
alias checksum='shasum -a 256' #si dupa pui fisieru sau fisierele care vrei sa le vezi

###managing storage

#sa-ti apara human readable indiferent, aint nobody know what a fkin mipbyte is
alias du="du -h"
#sa vezi cat de mare e fix doar folderu in care esti tu acm
alias sizepwd='du -d 0'
#sorteaza toate fisierele din folderu asta dupa size
alias sort-size="du -sh * | sort -h"
#sorteaza folderele si fisierle recursiv
alias sort-recur="du -ah | sort -h"

#sorteaza homebrewurile dupa size
#da deocamdata nu e folositan nicaieri ca nu-mi dau eu seama
get_brew_size() {

  data=$(brew list | xargs -n1 -P8 -I {} sh -c "brew info {} | egrep '[0-9]* files, ' | sed 's/^.*[0-9]* files, \(.*\)).*$/{} \1/'" | sort -h -r -k2 - | column -t)

  echo "Datele de la formule caske:"
  echo $"data"

  total=0

  # Process each line
  while IFS= read -r line; do
    # Extract the size and unit using regex
    size=$(echo "$line" | grep -oP '\d+(\.\d+)?(?=[KM]B)')
    unit=$(echo "$line" | grep -oP '(?<=\d)([KM]B)')

    # Convert sizes to KB
    if [[ $unit == "MB" ]]; then
      size_kb=$(echo "$size * 1024" | bc)
    elif [[ $unit == "KB" ]]; then
      size_kb=$size
    else
      size_kb=0
    fi

    # Add to the total
    total=$(echo "$total + $size_kb" | bc)
  done <<<"$data"

  # Convert total to MB for better readability
  total_mb=$(echo "scale=2; $total / 1024" | bc)

  echo "Total size: $total_kb KB"
  echo "Total size: $total_mb MB"
}

#deocamdata nu prea merge astsa deci functia de sus nu-i folosita
#alias brew-size='get_brew_size'
alias brew-size="brew list | xargs -n1 -P8 -I {} sh -c \"brew info {} | egrep '[0-9]* files, ' | sed 's/^.*[0-9]* files, \(.*\)).*$/{} \1/'\" | sort -h -r -k2 - | column -t"

#gen mereu doar asta fac orc
alias brew-clean='brew cleanup --prune=all'

##kkturi random gen literally
alias getrandom='cat /dev/urandom | base64 | tr -dc '0-9a-zA-Z' | head -c50'

#######################################################################
## EXPORTS (sectiune mutata in ~/.zprofile lmao ####
#######################################################################

###############
## SOURCES #### nu prea trebuie mai multe
###############

#configu de prompt

parse_git_branch() {
  git branch 2>/dev/null | sed -n -e 's/^\* \(.*\)/[\1]/p'
}

COLOR_DEF='%f'
COLOR_USR='%F{243}'
COLOR_DIR='%F{197}'
COLOR_GIT='%F{39}'
NEWLINE=$'\n'
# setopt PROMPT_SUBST
export PROMPT='${COLOR_USR}%n@%M ${COLOR_DIR}${PWD#"${PWD%/*/*}/"} ${COLOR_GIT}$(parse_git_branch)${COLOR_DEF}${NEWLINE}% '

# autoload -Uz compinit
# compinit -u

# shellcheck shell=bash
eval "$(fzf --bash)"

# shellcheck shell=bash

# =============================================================================
#
# Utility functions for zoxide.
#

# pwd based on the value of _ZO_RESOLVE_SYMLINKS.
function __zoxide_pwd() {
  \command cygpath -w "$(\builtin pwd -P)"
}

# cd + custom logic based on the value of _ZO_ECHO.
function __zoxide_cd() {
  # shellcheck disable=SC2164
  \builtin cd -- "$@"
}

# =============================================================================
#
# Hook configuration for zoxide.
#

# Hook to add new entries to the database.
__zoxide_oldpwd="$(__zoxide_pwd)"

function __zoxide_hook() {
  \builtin local -r retval="$?"
  \builtin local pwd_tmp
  pwd_tmp="$(__zoxide_pwd)"
  if [[ ${__zoxide_oldpwd} != "${pwd_tmp}" ]]; then
    __zoxide_oldpwd="${pwd_tmp}"
    \command zoxide add -- "${__zoxide_oldpwd}"
  fi
  return "${retval}"
}

# Initialize hook.
if [[ ${PROMPT_COMMAND:=} != *'__zoxide_hook'* ]]; then
  PROMPT_COMMAND="__zoxide_hook;${PROMPT_COMMAND#;}"
fi

# Report common issues.
function __zoxide_doctor() {
  [[ ${_ZO_DOCTOR:-1} -eq 0 ]] && return 0
  # shellcheck disable=SC2199
  [[ ${PROMPT_COMMAND[@]:-} == *'__zoxide_hook'* ]] && return 0
  # shellcheck disable=SC2199
  [[ ${__vsc_original_prompt_command[@]:-} == *'__zoxide_hook'* ]] && return 0

  _ZO_DOCTOR=0
  \builtin printf '%s\n' \
    'zoxide: detected a possible configuration issue.' \
    'Please ensure that zoxide is initialized right at the end of your shell configuration file (usually ~/.bashrc).' \
    '' \
    'If the issue persists, consider filing an issue at:' \
    'https://github.com/ajeetdsouza/zoxide/issues' \
    '' \
    'Disable this message by setting _ZO_DOCTOR=0.' \
    '' >&2
}

# =============================================================================
#
# When using zoxide with --no-cmd, alias these internal functions as desired.
#

__zoxide_z_prefix='z#'

# Jump to a directory using only keywords.
function __zoxide_z() {
  __zoxide_doctor

  # shellcheck disable=SC2199
  if [[ $# -eq 0 ]]; then
    __zoxide_cd ~
  elif [[ $# -eq 1 && $1 == '-' ]]; then
    __zoxide_cd "${OLDPWD}"
  elif [[ $# -eq 1 && -d $1 ]]; then
    __zoxide_cd "$1"
  elif [[ $# -eq 2 && $1 == '--' ]]; then
    __zoxide_cd "$2"
  elif [[ ${@: -1} == "${__zoxide_z_prefix}"?* ]]; then
    # shellcheck disable=SC2124
    \builtin local result="${@: -1}"
    __zoxide_cd "${result:${#__zoxide_z_prefix}}"
  else
    \builtin local result
    # shellcheck disable=SC2312
    result="$(\command zoxide query --exclude "$(__zoxide_pwd)" -- "$@")" &&
      __zoxide_cd "${result}"
  fi
}

# Jump to a directory using interactive search.
function __zoxide_zi() {
  __zoxide_doctor
  \builtin local result
  result="$(\command zoxide query --interactive -- "$@")" && __zoxide_cd "${result}"
}

# =============================================================================
#
# Commands for zoxide. Disable these using --no-cmd.
#

\builtin unalias cd &>/dev/null || \builtin true
function cd() {
  __zoxide_z "$@"
}

\builtin unalias cdi &>/dev/null || \builtin true
function cdi() {
  __zoxide_zi "$@"
}

# Load completions.
# - Bash 4.4+ is required to use `@Q`.
# - Completions require line editing. Since Bash supports only two modes of
#   line editing (`vim` and `emacs`), we check if either them is enabled.
# - Completions don't work on `dumb` terminals.
if [[ ${BASH_VERSINFO[0]:-0} -eq 4 && ${BASH_VERSINFO[1]:-0} -ge 4 || ${BASH_VERSINFO[0]:-0} -ge 5 ]] &&
  [[ :"${SHELLOPTS}": =~ :(vi|emacs): && ${TERM} != 'dumb' ]]; then

  function __zoxide_z_complete_helper() {
    READLINE_LINE="cd ${__zoxide_result@Q}"
    READLINE_POINT=${#READLINE_LINE}
    bind '"\e[0n": accept-line'
    \builtin printf '\e[5n' >/dev/tty
  }

  function __zoxide_z_complete() {
    # Only show completions when the cursor is at the end of the line.
    [[ ${#COMP_WORDS[@]} -eq $((COMP_CWORD + 1)) ]] || return

    # If there is only one argument, use `cd` completions.
    if [[ ${#COMP_WORDS[@]} -eq 2 ]]; then
      \builtin mapfile -t COMPREPLY < <(
        \builtin compgen -A directory -- "${COMP_WORDS[-1]}" || \builtin true
      )
    # If there is a space after the last word, use interactive selection.
    elif [[ -z ${COMP_WORDS[-1]} ]]; then
      # shellcheck disable=SC2312
      __zoxide_result="$(\command zoxide query --exclude "$(__zoxide_pwd)" --interactive -- "${COMP_WORDS[@]:1:${#COMP_WORDS[@]}-2}")" && {
        # In case the terminal does not respond to \e[5n or another
        # mechanism steals the response, it is still worth completing
        # the directory in the command line.
        COMPREPLY=("${__zoxide_z_prefix}${__zoxide_result}/")

        # Note: We here call "bind" without prefixing "\builtin" to be
        # compatible with frameworks like ble.sh, which emulates Bash's
        # builtin "bind".
        bind -x '"\e[0n": __zoxide_z_complete_helper'
        \builtin printf '\e[5n' >/dev/tty
      }
    fi
  }

  \builtin complete -F __zoxide_z_complete -o filenames -- cd
  \builtin complete -r cdi &>/dev/null || \builtin true
fi

# =============================================================================
#
# To initialize zoxide, add this to your shell configuration file (usually ~/.bashrc):
#
eval "$(zoxide init bash)"
