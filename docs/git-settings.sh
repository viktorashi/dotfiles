git config --global alias.st status
git config --global alias.s status
git config --global alias.f fetch
git config --global alias.p pull
git config --global alias.P push
git config --global alias.c commit
git config --global alias.b branch
git config --global alias.co checkout
git config --global alias.sw switch
git config --global alias.a add
git config --global alias.d diff
git config --global alias.a add
git config --global alias.l log
git config --global alias.t tag

<<<<<<< Updated upstream
git config --global core.editor "nvim"
=======
git config --global core.editor "vim"

# kktu asta e sa imi fac conflictele misto
# [diff]
#     tool = vimdiff
# [merge]
#     tool = vimdiff
#     conflictstyle = zdiff3
# [mergetool "vimdiff"]
#     cmd = nvim -d $LOCAL $BASE $REMOTE $MERGED \
#           -c '$wincmd w' -c 'wincmd J'
>>>>>>> Stashed changes
