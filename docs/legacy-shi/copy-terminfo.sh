# if whatever os you're ssh'ed into doesn't support the terminal your currently using (you cant clear and other things)

#if the host os supports it
remote_name="acas"
infocmp -x ghostty | ssh $remote_name "tic -x -"

#WARNING: Some older tic's dont support reading from stdin, so you gotta do this next two step proccess detailed:
#from local (newer) machine:
infocmp -x ghostty >ghostty.terminfo
scp ghostty.terminfo $remote_name:~/
rm ghostty.terminfo

#from older:
#then from inside the remote
tic -x ghostty.terminfo
