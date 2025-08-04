echo "Now cloning dă marfă"

git clone --bare https://github.com/viktorashi/my-config "$HOME"/.cfg
echo ".cfg" >>.gitignore #avoiding reccusrive weirdness
alias config='git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
alias config='conf'

conf config --local status.showUntrackedFiles no #only account for the files you specifically mention
conf checkout
conf config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
conf fetch
conf branch --set-upstream-to=origin/main
conf switch mac
conf branch --set-upstream-to=origin/mac
conf switch windows10
conf branch --set-upstream-to=origin/windows10

cd docs/
#no hackerino
chmod +x git-settings.sh
./git-settings.sh
