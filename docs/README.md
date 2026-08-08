#### Download all scripts from [here](https://download-directory.github.io/?url=https%3A%2F%2Fgithub.com%2Fviktorashi%2Fmy-config%2Ftree%2Fmain%2Fdocs) and run them inside `bash, zsh`

### Orr copy-paste these from below, but you'll need to get `curl` first

> [!IMPORTANT]
> Beforehand for Windows users!
> Follow [The MSYS2 tutorial](https://www.msys2.org) for installing it.
> It automatically adds `bash`, which can later be accessed directly through the Windows Terminal via the command `sh`.
> Inside the `MSYS2` terminal run

```
pacman -S curl zsh
```

Add
```
C:\msys64\mingw64\bin
```
to your path 


then just GET THE config.
```bash
curl -fsSL https://raw.githubusercontent.com/viktorashi/dotfiles/main/docs/backup-remove-and-clone.sh | sh
```

> [!IMPORTANT]
> If on Windows, you need to hard-link *a lot of stuff* that's tracked, so run this 
```
~/docs/vindovs/link-windows-thangs.bat
```

Restart your `shell`. _Voila!_

Now checkout into whichever OS you have
```bash
conf sw windows10 #this works for 11 as well
```

then run the specific
```bash
~/docs/install-init-stuff.sh
```
for that OS


Now you'll be able to run the following commands:
##### You should have my lazy-aah aliases so you can use things like

```bash
conf status
#or ,even more lazily:
conf s

cons sw mac # if you're one of those

conf pull #after you've bothered me

#whenever you add a new file and want it to be tracked:
conf add <filename>

#or shortcut if you've added new plugin files in neovim / docs
confad

#even view it nicely if you have lazygit:
configlazygit
```

You can check them out in `~/docs/aliases.sh`

# Don't worry about these if you're on mac, just run `~/docs/install-init-stuff.sh`. Simmilar ones will be coming for other branches as well at some point.
## Other dependecies 

- [git Delta](https://dandavison.github.io/delta/installation.html)
- [node](https://docs.npmjs.com/downloading-and-installing-node-js-and-npm)
- [neovim](https://neovim.io)

Installing these on Windows:
Get [Scoop](https://scoop.sh).
and do

```sh
scoop install neovim delta zoxide fd
```

For `node` install [fnm](https://github.com/Schniz/fnm) and do:

```sh
fnm install 22
fnm default 22
```

For [Rust](https://www.rust-lang.org) development:
On Windows you need Visual Studio C/C++ Windows Development Toolchain before even installing `rustup`. After you get it:

```
rustup update
rustup component add rust-analyzer
rustup component add rustfmt
```
Now just make sure you on the `Private` Wifi network (if you know you know) and run the all-lazily:

```sh
nv
```

#### Different neovim notes for binds and stuffs

Starting a command with `":term"` takes the output of the command and spits it into a buffer
FINALLYyY found da issue

✅✅✅✅ one more _Voila!_ ✅✅✅✅

#### Contributing (u wont, dont lie)

To generate these docs I've used [pandoc](https://pandoc.org) with THIS
HIGHLY RECOMMENDED FILTER FOR `pandoc`:
[py-pandoc-include-code](https://github.com/veneres/py-pandoc-include-code)

and you can simply run:

```bash
make
```

if your machine has [GNU Make](https://www.gnu.org/software/make)

else just do

```bash
pandoc --filter=py-pandoc-include-code ~/docs/read-me.md -o ~/docs/README.md
```

before commiting orrr put it into that into the file go into
`~/.cfg/hooks/pre-commit` to make it a pre-commmit hook like ya boi
