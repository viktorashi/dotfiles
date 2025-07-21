# All scripts are in  `docs`

## Run it in `bash, zsh` etc or create a `script.sh` for each and run it in a GNU shell (even on windows)

Download all scripts from [here](https://download-directory.github.io/?url=https%3A%2F%2Fgithub.com%2Fviktorashi%2Fmy-config%2Ftree%2Fmain%2Fdocs)

### Back it up terry

just in case

`backup.sh`

```{.sh include=backup.sh}
```

### Cloning the actual config

`cloning-setup.sh`

```{.sh include=cloning-setup.sh}
```

Now restart your `shell`. _Voila!_

##### You should have my lazy-aah aliases so you can use things like

```bash
conf status
#or ,even more lazily:
conf s

#whenever you add a new file and want it to be tracked:
conf add <filename>

#even view it nicely if you have lazygit:
configlazygit
```

> [!IMPORTANT]
If on Windows you need to hard-link .config/nvim to %USERPROFILE%AppData\Local\nvim and nvim-data as well!! so Neovim sees it!

Run these IN THE OG CMD, _not_ PowerShell!!

`link-nvim.bat`

```{.bat include=link-nvim.bat}
```

`link-nvim-data.bat`

```{.bat include=link-nvim-data.bat}
```

to generate these docs I've installed THIS HIGHLY RECOMMENDED FILTER FOR `pandoc`, [py-pandoc-include-code](https://github.com/veneres/py-pandoc-include-code)  
and you can simply run:

```bash
pandoc --filter=py-pandoc-include-code ~/docs/read-me.md -o ~/docs/README.md
```

before commiting orrr put it into that into the file go into `~/.cfg/hooks/pre-commit`
to make it a pre-commmit hook like ya boi
