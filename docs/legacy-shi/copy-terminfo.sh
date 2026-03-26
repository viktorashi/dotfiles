# if whatever os you're ssh'ed into doesn't support the terminal your currently using (you cant clear and other things)

#if the host os supports it
infocmp -x ghostty | ssh centos-vm "tic -x -"

#WARNING: Some older tic's dont support reading from stdin, so you gotta do this next two step proccess detailed:
#from local (newer) machine:
infocmp -x ghostty >ghostty.terminfo
scp ghostty.terminfo centos-vm:~/

#from older:
# then after compiling it from inside the VM
tic -x ghostty.terminfo
