# 1. Disable the dead mirrorlists
sudo sed -i 's/^mirrorlist=/#mirrorlist=/g' /etc/yum.repos.d/CentOS-Base.repo

# 2. Enable the baseurls
sudo sed -i 's/^#baseurl=/baseurl=/g' /etc/yum.repos.d/CentOS-Base.repo

# 3. Swap the old mirror address for the vault archive
sudo sed -i 's/mirror.centos.org\/centos\/$releasever/archive.kernel.org\/centos-vault\/5.11/g' /etc/yum.repos.d/CentOS-Base.repo

#acum poti sa dai refresh la repourile astea
sudo yum clean all

# sidai install la ce vrei tu gen
sudo yum install gcc hexedit nasm binutils strace ltrace
