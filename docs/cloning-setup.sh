echo "Now cloning dă marfă"

git clone --bare https://github.com/viktorashi/my-config "$HOME"/.cfg
echo ".cfg" >>.gitignore #avoiding reccusrive weirdness
config='git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

$(config) config --local status.showUntrackedFiles no #only account for the files you specifically mention
$(config) checkout
$(config) config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
$(config) fetch
$(config) branch --set-upstream-to=origin/main
$(config) switch mac
$(config) branch --set-upstream-to=origin/mac
$(config) switch windows10
$(config) branch --set-upstream-to=origin/windows10

cd docs/
#no hackerino
chmod +x git-settings.sh
./git-settings.sh
