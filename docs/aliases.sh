# s-au mutat aici toate sa fie frumix

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
alias gr='egrep -irna'
#cuz who cares about those
alias tree='tree --gitignore'
#ai numa grija dupa n-o sa-ti mai mearga ghostcript daca ai nevoie de el, da nu afecteaza ce chestii foloesti TeX si asa, nu cred
#pot sa fac asta sau sa dau la unele
#	git config --global alias.<alias-name> "<aliased-git-subcommand>"
#	da problema e ca dupa nu mai poti sa faci daor "gs" tre sa faci "git s" sau "git gs" or smth

alias gs='git status'
alias gp='git push'
alias gc='git commit -a && git push'
alias gpl='git pull'
alias gd='git diff'
alias gds='git diff --staged'
alias ga='git add .'
alias gl='git log --graph --pretty --decorate --all'
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
alias ghm='gh pr merge --admin -d && git remote prune origin'

config_worktree_folder="$HOME"
git_dir="${config_worktree_folder}/.cfg/"
alias configotofolder="cd ${config_worktree_folder}"
alias config="git --git-dir=${git_dir} --work-tree=${config_worktree_folder}"
alias conf='config'
alias configst="config status"
alias configadd="config add ${config_worktree_folder}/.config/nvim && config add ${config_worktree_folder}/docs && config status"
alias confadd='configadd'
alias confad='configadd'
alias confs='conf status'
alias confd='conf diff'
alias confds='conf diff --staged'
alias configlazygit="lazygit --git-dir=${config_worktree_folder}/.cfg/ --work-tree=${config_worktree_folder}"
alias conflazygit='configlazygit'

#probabil o sa dea doar conflict
#daca nu merge ii dai chcekout in ala cu buba si bagi confict resolution
alias confupdate='config fetch $git_dir main:mac && config fetch $git_dir main:windows10'
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
#alias py='python3'
alias python='python3'
alias pip='pip3'
alias ls='ls -a'
alias ll='ls -l'
#FRFRFF fr for reals
alias fr='clear && flask --app . --debug run' # dupa pui --app <numele la ce package ii zice la aplicatie> run
#muult prea des dau acum frfr
alias cr='clear && cargo run'
alias ct='clear && cargo test'
alias cb='clear && cargo build'

alias r='radian  --ask-save --save --restore-data --debug'

#alias fr='flutter run'
#acm de cand cu zoxide nu prea mai e nevoie lmao
#alias licenta='cd ~/Documents/toate-de-la-faculta-trecut/licenta/texuri/bachelor-thesis-repo/bachelor-thesis'

# Set up fzf key bindings
alias iv='fzf -m --preview="bat --color=always {}" --bind "enter:become(nvim {+})"'
alias nv='nvim'

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
alias getrandom='cat /dev/urandom | base64 | tr -dc '0-9a-zA-Z' | head -c50'
