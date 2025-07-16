echo "Now cloning dă marfă"

git clone --bare https://github.com/viktorashi/my-config "$HOME"/.cfg
echo ".cfg" >>.gitignore #avoiding reccusrive weirdness
alias config='git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
config config --local status.showUntrackedFiles no #only account for the files you specifically mention
config checkout
