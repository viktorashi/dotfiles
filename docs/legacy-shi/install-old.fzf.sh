#SIKE old fzf is actually fzy

curl -LO https://github.com/jhawthorn/fzy/releases/download/1.0/fzy-1.0.tar.gz
scp fzy-1.0.tar.gz centos-vm:~/

#si dupa ssh in el

tar -xzvf fzy-1.0.tar.gz
cd fzy-1.0 || exit
make
sudo make install

rm -rf fzy-1.0*
