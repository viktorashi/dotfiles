# s-au mutat aici toate sa fie frumix

# Let the shell prompt decide how virtual environments are displayed.
export VIRTUAL_ENV_DISABLE_PROMPT=1

# Fresh tmux panes can inherit a stale Python venv from the tmux server
# environment. Strip that implicit state so project venvs are only entered
# explicitly (for example via `sv`).
if [ -n "${VIRTUAL_ENV-}" ]; then
  case ":$PATH:" in
  *":$VIRTUAL_ENV/bin:"*)
    PATH=$(printf '%s' "$PATH" | awk -v RS=: -v ORS=: -v drop="$VIRTUAL_ENV/bin" '$0 != drop { print }' | sed 's/:$//')
    export PATH
    ;;
  esac
  unset VIRTUAL_ENV
  unset VIRTUAL_ENV_PROMPT
fi

tmux_see_sockets_statuses() {
  for s in /tmp/tmux-$(id -u)/*; do
    printf '%s: ' "$s"
    tmux -S "$s" ls >/dev/null 2>&1 && echo live || echo dead
  done
}

tmux_kill_dead_sockets() {
  for s in /tmp/tmux-$(id -u)/*; do
    base=$(basename "$s")
    [ "$base" = default ] && continue
    tmux -S "$s" ls >/dev/null 2>&1 || rm -f -- "$s"
  done

}

alias cls='clear'
alias clc='clear'
alias cl='clear'
alias ..='cd ..'
alias ...='cd ../../'
alias l='ls'
#i always mess this up so ye
alias sc='source ~/.zshrc'
alias scb='source ~/.bashrc'
alias scz='source ~/.zshrc'
alias sour='source'
alias sv='source .venv/bin/activate'
alias gr='egrep -irna'
function tree {
     br -c :pt "$@"
}


#ai numa grija dupa n-o sa-ti mai mearga ghostcript daca ai nevoie de el, da nu afecteaza ce chestii foloesti TeX si asa, nu cred
#pot sa fac asta sau sa dau la unele
#	git config --global alias.<alias-name> "<aliased-git-subcommand>"
#	da problema e ca dupa nu mai poti sa faci daor "gs" tre sa faci "git s" sau "git gs" or smth

alias gs='git status'
alias gp='git push'
alias gc='git commit -S -a && git push'
alias gt='git tag -S'
alias gcl='git clone'
alias gpl='git pull'
alias gd='git diff'
alias gds='git diff --staged'
alias ga='git add .'
alias gl='git log --graph --all --show-signature --format="%C(yellow)commit %H%C(auto)%d%n%C(bold)Author: %C(reset)%an <%ae>%n%C(bold)Date:   %C(reset)%C(green)%ad%C(reset) [Orig: %ai]%n%n    %s%n" --date=local'
# iti face semnatura la toate commiturile (inclusiv cel dat ca argument) in sus non-interactiv
git-sign-from-commit() {
  git rebase --exec "git commit --amend --no-edit -n -S" "$1~1"
}

# Signs ONLY the specific commit provided as an argument, non-interactively
git-sign-single-commit() {
  if [ -z "$1" ]; then
    echo "Error: Please provide a commit hash."
    return 1
  fi

  # Temporarily override the editor to inject the 'exec' command ONLY after the very first line (the target commit)
  GIT_SEQUENCE_EDITOR='f() { awk "NR==1{print; print \"exec git commit --amend --no-edit -n -S\"; next} 1" "$1" > "$1.tmp" && mv "$1.tmp" "$1"; }; f' \
    git rebase -i "$1~1"
}

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
alias ghm='gh pr merge --admin -d && git remote prune origin'

#store in stash fara sa le scoata din worktree, si doar la staged changes
gss() {
  local msg="${1:-Stashed staged changes}"

  # 1. Check if there are actually staged changes
  if git diff --cached --quiet; then
    echo "No staged changes to stash."
    return 0
  fi

  git stash push --staged -m "$msg" && git stash apply --index
}

git_dir="$HOME/.cfg/"
alias confgotofolder="cd $HOME"
conf() {
  # If the command is checkout, switch, co, or sw, wrap it safely to auto-backup conflicts
  if [[ "$1" = "checkout" || "$1" = "switch" || "$1" = "co" || "$1" = "sw" ]]; then
    local tmp_err
    tmp_err=$(mktemp)
    
    git --git-dir="${git_dir}" --work-tree="$HOME" "$@" 2> "$tmp_err"
    local exit_code=$?
    
    if [ $exit_code -ne 0 ]; then
      local err_content
      err_content=$(cat "$tmp_err")
      
      # Parse the conflicting files from git output (lines starting with a tab)
      local conflicting_files
      conflicting_files=$(echo "$err_content" | grep -E $'^\t' | sed $'s/^\t//')
      
      if [ -n "$conflicting_files" ]; then
        # Find a unique incremental backup directory name
        local base_dir="$HOME/backup"
        local counter=1
        local backup_dir="${base_dir}_${counter}"
        while [ -d "$backup_dir" ]; do
          counter=$((counter + 1))
          backup_dir="${base_dir}_${counter}"
        done
        
        echo "⚠️  Conflicting files detected. Backing up to: $backup_dir"
        mkdir -p "$backup_dir"
        
        while IFS= read -r file; do
          [ -z "$file" ] && continue
          local local_path="$HOME/$file"
          if [ -e "$local_path" ]; then
            local dest_path="$backup_dir/$file"
            mkdir -p "$(dirname "$dest_path")"
            echo "📦 Moving $file -> $dest_path"
            mv "$local_path" "$dest_path"
          fi
        done <<< "$conflicting_files"
        
        rm -f "$tmp_err"
        
        # Retry checkout/switch
        echo "🔄 Retrying command: conf $@"
        git --git-dir="${git_dir}" --work-tree="$HOME" "$@"
        return $?
      else
        cat "$tmp_err" >&2
        rm -f "$tmp_err"
        return $exit_code
      fi
    else
      rm -f "$tmp_err"
      return 0
    fi
  else
    # Run the standard git command
    git --git-dir="${git_dir}" --work-tree="$HOME" "$@"
  fi
}
alias grp='git remote prune origin && git pull --prune'
alias confad="conf add $HOME/.config/nvim && conf add $HOME/docs && conf status"
alias confs='conf status'
alias confd='conf diff'
alias confds='conf diff --staged'
alias conflazygit="lazygit --git-dir=$HOME/.cfg/ --work-tree=$HOME"
alias clazygit="lazygit --git-dir=$HOME/.cfg/ --work-tree=$HOME"
alias lg='lazygit'

#probabil o sa dea doar conflict
#daca nu merge ii dai chcekout in ala cu buba si bagi confict resolution
alias confupdate='conf fetch $git_dir main:mac && conf fetch $git_dir main:windows10'
alias confupdatemason='~/docs/configupdatemason.sh'
alias confupdateallbranches='conf switch mac && conf merge main --no-edit && conf switch windows10 && conf merge main --no-edit && conf push --all'

#sunt prea putoare
alias m='make'
alias dp='docker ps -a'
#alias ds='docker start'

#amandoua astea bune la rescuenow
#alias dr='deno task run'
#alias fpg='flutter pub get'

alias di='docker image'
alias dil='docker image list'
alias dcu='docker compose up'
alias dcd='docker compose down'
#ba deci mi-au dat la dureri kkturile asteaa, nu le mai decomenta gataa
alias py='python3'
alias python='python3'
alias ls='ls -a'
alias ll='ls -l'
#FRFRFF fr for reals
alias fr='clear && flask --app . --debug run' # dupa pui --app <numele la ce package ii zice la aplicatie> run
#muult prea des dau acum frfr
alias cr='clear && cargo run'
alias ct='clear && cargo test'
alias cb='clear && cargo build'

alias r='clear && radian  --ask-save --save --restore-data --debug'
alias R="clear && R --save"
#alias fr='flutter run'
#acm de cand cu zoxide nu prea mai e nevoie lmao
#alias licenta='cd ~/Documents/toate-de-la-faculta-trecut/licenta/texuri/bachelor-thesis-repo/bachelor-thesis'

# Set up fzf key bindings
alias iv='fzf -m --preview="bat --color=always {}" --bind "enter:become(nvim {+})"'
_rg_pick_open() {
  local opener="$1"
  fzf -m --disabled --prompt="rg> " \
    --bind "start:reload:rg --files" \
    --bind "change:reload:rg --files-with-matches --smart-case --hidden -g '!.git' -- {q} 2>/dev/null || true" \
    --bind "enter:become(${opener} {+})" \
    --preview "if [ -n \"{q}\" ]; then rg --smart-case --line-number --color=always -C 2 -- {q} {} 2>/dev/null || bat --color=always {}; else bat --color=always {}; fi"
}
alias gv='_rg_pick_open nvim'
alias nv='nvim'
alias t='tmux'

##############
#de editoare##

##############
#deschide pycharm in curr_dirkoilk;
alias charm='open -na "PyCharm Professional Edition.app" .'
alias char='open -na "PyCharm Professional Edition.app" .'
alias cha='open -na "PyCharm Professional Edition.app" .'
alias ch='open -na "PyCharm Professional Edition.app" .'
alias o='open .'

alias c='code .'
alias idea='idea .'
alias oc='opencode'
#sa dea follow la redirecturi
alias curl='curl -L'
#vezi ce programe folosesc un anumit port
alias findport='sudo lsof -i '
#cam mereu vreau doar sa se opreasca direct cand il gaseste
alias ping='ping -o'
#dai ping acasa sa vezi macar daca merge chestia
alias pingacas='ping viktorashi.home.ro'
#connecteazate la ssh acasa
alias sshacas='ssh victor@viktorashi.home.ro'
#pt codespacu pe care pot sa builduiesc rustu de linux
#alias sshcodespace='ssh cs.obscure-fishstick-w9rjqqv46x9c9975.develop'
#alias sshcs='ssh cs.obscure-fishstick-w9rjqqv46x9c9975.develop'
#alias sshraspi='ssh pi@10.5.202.61'
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
#vezi ce viteza de write-speed are un drive pe care esti acm
alias write-speed='dd if=/dev/zero of=/tmp/output bs=8k count=10k; rm -f /tmp/output'
#da vezi ca ai nevoie de destul de mult spatiu cat sa poata sa-ti scrie experimental pe el si dupa sa-ti zica cat a durat sa-ti scrie

#nu stiu daca e musai recomandata asta tbh =))
alias shutdown='sudo shutdown -h now'

#sorteaza homebrewurile dupa size
#da deocamdata nu e folositan nicaieri ca nu-mi dau eu seama
get_brew_size() {

  data=$(brew list | xargs -n1 -P8 -I {} sh -c "brew info {} | egrep '[0-9]* files, ' | sed 's/^.*[0-9]* files, \(.*\)).*$/{} \1/'" | sort -h -r -k2 - | column -t)

  echo "Datele de la formule caske:"
  echo "$data"

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

  echo "Total size: $total KB"
  echo "Total size: $total_mb MB"
}

#deocamdata nu prea merge astsa deci functia de sus nu-i folosita
# ar trebui sa dea marimea la toate brew sizeurile
#alias brew-size='get_brew_size'
alias brew-size="brew list | xargs -n1 -P8 -I {} sh -c \"brew info {} | egrep '[0-9]* files, ' | sed 's/^.*[0-9]* files, \(.*\)).*$/{} \1/'\" | sort -h -r -k2 - | column -t"

#gen mereu doar asta fac orc
alias brew-clean='brew cleanup --prune=all'

##kkturi random gen literally
alias getrandom="cat /dev/urandom | base64 | tr -dc '0-9a-zA-Z' | head -c50"

export XDG_CONFIG_HOME="$HOME/.config"

# Created by `pipx` on 2025-10-25 14:34:10
export PATH="$PATH:/Users/viktorashi/.local/bin"
export PATH="$PATH:/Users/viktorashi/.cargo/bin"
