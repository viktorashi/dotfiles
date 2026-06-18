###############
## ALIASES ####
###############

# Restore terminal to a sane state before each prompt.
# Fixes jumbled output after exiting fullscreen programs (nvim, htop, less, etc.)
autoload -Uz add-zsh-hook
_fix_terminal() {
    # Resets text, character set, re-enables line wrap, and forces block cursor
    printf '\e[0m\e(B\e[?7h\e[2 q'
}
add-zsh-hook precmd _fix_terminal

source ~/docs/shared.sh

# Persist command history across tmux resurrect restores by giving each
# logical pane position its own history file.
HISTSIZE=50000
SAVEHIST=50000
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_FIND_NO_DUPS
setopt EXTENDED_HISTORY

_configure_history_file() {
    local hist_root pane_key
    hist_root="$HOME/.zsh_history.d"
    mkdir -p "$hist_root"

    if [[ -n "${TMUX_PANE-}" ]]; then
        pane_key="$(tmux display-message -p -t "${TMUX_PANE}" '#{session_name}:#{window_index}.#{pane_index}' 2>/dev/null)"
        pane_key="${pane_key//[^A-Za-z0-9_.:-]/_}"
        [[ -n "$pane_key" ]] || pane_key="tmux_unknown"
        export HISTFILE="${hist_root}/history_${pane_key}.zsh"
    else
        export HISTFILE="$HOME/.zsh_history"
    fi

    if [[ "${__ZSH_HISTORY_LOADED_FOR-}" != "$HISTFILE" && -r "$HISTFILE" ]]; then
        fc -R "$HISTFILE"
    fi
    export __ZSH_HISTORY_LOADED_FOR="$HISTFILE"
}
_configure_history_file

#######################################################################
## EXPORTS (sectiune mutata in ~/.zprofile lmao ####
#######################################################################

###############
## SOURCES #### nu prea trebuie mai multe
###############

# Set up fzf fuzzy completion
source <(fzf --zsh)

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
. "$HOME/.cargo/env"
[[ "$TERM_PROGRAM" == "vscode" ]] && . "/home/istan/.vscode-server/bin/0f0d87fa9e96c856c5212fc86db137ac0d783365/out/vs/workbench/contrib/terminal/common/scripts/shellIntegration-rc.zsh"

#configu de prompt
parse_git_branch() {
    git branch 2> /dev/null | sed -n -e 's/^\* \(.*\)/[\1]/p'
}
active_env_prompt() {
    if [ -n "${VIRTUAL_ENV-}" ]; then
        printf '(%s) ' "${VIRTUAL_ENV:t}"
    elif [ -n "${CONDA_DEFAULT_ENV-}" ] && [ "${CONDA_DEFAULT_ENV}" != "base" ]; then
        printf '(%s) ' "${CONDA_DEFAULT_ENV}"
    fi
}
COLOR_DEF='%f'
COLOR_USR='%F{243}'
COLOR_DIR='%F{197}'
COLOR_GIT='%F{39}'
NEWLINE=$'\n'
setopt PROMPT_SUBST
PROMPT='$(active_env_prompt)${COLOR_USR}%n@%M ${COLOR_DIR}${PWD#"${PWD%/*/*}/"} ${COLOR_GIT}$(parse_git_branch)${COLOR_DEF}${NEWLINE}% '

# New tabs inherit the terminal app environment, not necessarily ~/.profile.
# Point interactive zsh shells at the live gpg-agent SSH socket every time.
export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
export GPG_TTY="$(tty)"
gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1

fpath=(~/.zsh/completions $fpath)
autoload -Uz compinit
compinit -u

# =============================================================================
#
# Utility functions for zoxide.
#

# pwd based on the value of _ZO_RESOLVE_SYMLINKS.
function __zoxide_pwd() {
    \builtin pwd -P
}

# cd + custom logic based on the value of _ZO_ECHO.
function __zoxide_cd() {
    # shellcheck disable=SC2164
    \builtin cd -- "$@" && __zoxide_pwd
}

# =============================================================================
#
# Hook configuration for zoxide.
#

# Hook to add new entries to the database.
function __zoxide_hook() {
    # shellcheck disable=SC2312
    \command zoxide add -- "$(__zoxide_pwd)"
}

# Initialize hook.
\builtin typeset -ga precmd_functions
\builtin typeset -ga chpwd_functions
# shellcheck disable=SC2034,SC2296
precmd_functions=("${(@)precmd_functions:#__zoxide_hook}")
# shellcheck disable=SC2034,SC2296
chpwd_functions=("${(@)chpwd_functions:#__zoxide_hook}")
chpwd_functions+=(__zoxide_hook)

# Report common issues.
function __zoxide_doctor() {
    [[ ${_ZO_DOCTOR:-1} -ne 0 ]] || return 0
    [[ ${chpwd_functions[(Ie)__zoxide_hook]:-} -eq 0 ]] || return 0

    _ZO_DOCTOR=0
    \builtin printf '%s\n' \
        'zoxide: detected a possible configuration issue.' \
        'Please ensure that zoxide is initialized right at the end of your shell configuration file (usually ~/.zshrc).' \
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

# Jump to a directory using only keywords.
function __zoxide_z() {
    __zoxide_doctor
    if [[ "$#" -eq 0 ]]; then
        __zoxide_cd ~
    elif [[ "$#" -eq 1 ]] && { [[ -d "$1" ]] || [[ "$1" = '-' ]] || [[ "$1" =~ ^[-+][0-9]$ ]]; }; then
        __zoxide_cd "$1"
    elif [[ "$#" -eq 2 ]] && [[ "$1" = "--" ]]; then
        __zoxide_cd "$2"
    else
        \builtin local result
        # shellcheck disable=SC2312
        result="$(\command zoxide query --exclude "$(__zoxide_pwd)" -- "$@")" && __zoxide_cd "${result}"
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

function cd() {
    __zoxide_z "$@"
}

function cdi() {
    __zoxide_zi "$@"
}

# Completions.
if [[ -o zle ]]; then
    __zoxide_result=''

    function __zoxide_z_complete() {
        # Only show completions when the cursor is at the end of the line.
        # shellcheck disable=SC2154
        [[ "${#words[@]}" -eq "${CURRENT}" ]] || return 0

        if [[ "${#words[@]}" -eq 2 ]]; then
            # Show completions for local directories.
            _cd -/

        elif [[ "${words[-1]}" == '' ]]; then
            # Show completions for Space-Tab.
            # shellcheck disable=SC2086
            __zoxide_result="$(\command zoxide query --exclude "$(__zoxide_pwd || \builtin true)" --interactive -- ${words[2,-1]})" || __zoxide_result=''

            # Set a result to ensure completion doesn't re-run
            compadd -Q ""

            # Bind '\e[0n' to helper function.
            \builtin bindkey '\e[0n' '__zoxide_z_complete_helper'
            # Sends query device status code, which results in a '\e[0n' being sent to console input.
            \builtin printf '\e[5n'

            # Report that the completion was successful, so that we don't fall back
            # to another completion function.
            return 0
        fi
    }

    function __zoxide_z_complete_helper() {
        if [[ -n "${__zoxide_result}" ]]; then
            # shellcheck disable=SC2034,SC2296
            BUFFER="cd ${(q-)__zoxide_result}"
            __zoxide_result=''
            \builtin zle reset-prompt
            \builtin zle accept-line
        else
            \builtin zle reset-prompt
        fi
    }
    \builtin zle -N __zoxide_z_complete_helper

    [[ "${+functions[compdef]}" -ne 0 ]] && \compdef __zoxide_z_complete cd
fi

# =============================================================================
#
# To initialize zoxide, add this to your shell configuration file (usually ~/.zshrc):
#
eval "$(zoxide init zsh)"




# fnm
FNM_PATH="/home/istan/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "$(fnm env --shell zsh)"
fi

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
eval "$(codex completion zsh)"
eval "$(batman --export-env)"
eval "$(register-python-argcomplete pipx)"

# bun completions
[ -s "/home/istan/.bun/_bun" ] && source "/home/istan/.bun/_bun"

eval "$(COMPLETE=zsh prek)"

# Fix vi-mode backspace: allow deleting past the insert-mode entry point
# (overrides /etc/zsh/zshrc which sets vi-backward-delete-char, which blocks this)
bindkey -M viins '^?' backward-delete-char

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/istan/miniforge3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/istan/miniforge3/etc/profile.d/conda.sh" ]; then
        . "/home/istan/miniforge3/etc/profile.d/conda.sh"
    else
        export PATH="/home/istan/miniforge3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# pnpm
export PNPM_HOME="/home/istan/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end
eval "$(/home/istan/.local/bin/mise activate zsh)"
