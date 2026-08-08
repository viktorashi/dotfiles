# All scripts are in  `docs`

## Run it in `bash, zsh` etc or create a `script.sh` for each and run it in a GNU shell (even on windows)

//TODO: explica cum pui bash pe windows

Download all scripts from [here](https://download-directory.github.io/?url=https%3A%2F%2Fgithub.com%2Fviktorashi%2Fmy-config%2Ftree%2Fmain%2Fdocs) and run them inside bash.

Orr copy-paste these from below, but you'll need to [get curl](https://curl.se/windows) from their website or with [Cygwin](https://www.cygwin.com) if you have it already.

#### Back up, clone and set up the repo

```bash
curl -fsSL https://raw.githubusercontent.com/viktorashi/my-config/main/docs/backup-and-clone.sh | sh
```

orr you have do them sepperately ig:

### Back it up terry

just in case

`backup.sh`

```
curl -fsSL https://raw.githubusercontent.com/viktorashi/my-config/main/docs/backup.sh | sh
```

### Cloning the actual config

`cloning-setup.sh`

```
curl -fsSL https://raw.githubusercontent.com/viktorashi/my-config/main/docs/cloning-setup.sh | sh
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
If on Windows you need to hard-link `.config/nvim` to `%USERPROFILE%AppData\Local\nvim` and `nvim-data` as well!! so Neovim sees it!

> [!WARNING]

Also I haven't tested if these scripts actually work on windows so feel free to tell me otherwise

Copy-paste this in _PowerShell_, _not_ the O.G. CMD.

`link-nvim.bat`

```
iwr https://raw.githubusercontent.com/viktorashi/my-config/main/docs/link-nvim.bat -OutFile "$env:TEMP\lnvim.bat"; & "$env:TEMP\lnvim.bat"; rm "$env:TEMP\lnvim.bat"
```

No need to link `nvim-data` as well, because it'll get automatically generated when first opening `nvim` with that config.
If you're curious about it anyways, Unix has it as `~/.local/share/nvim/`, and windows has them at `C:\Users\istan\AppData\Local\nvim-data`

You can use this to try it tho

```
iwr https://raw.githubusercontent.com/viktorashi/my-config/main/docs/link-nvim-data.bat -OutFile "$env:TEMP\lnvim.bat"; & "$env:TEMP\lnvim.bat"; rm "$env:TEMP\lnvim.bat"
```

#### Contributing (u wont, dont lie)

To generate these docs I've used [pandoc](https://pandoc.org) with THIS HIGHLY RECOMMENDED FILTER FOR `pandoc`: [py-pandoc-include-code](https://github.com/veneres/py-pandoc-include-code)  

and you can simply run:

```bash
make
```

if you're machine has [GNU Make](https://www.gnu.org/software/make)

else just do

```bash
pandoc --filter=py-pandoc-include-code ~/docs/read-me.md -o ~/docs/README.md
```

before commiting orrr put it into that into the file go into `~/.cfg/hooks/pre-commit`
to make it a pre-commmit hook like ya boi
