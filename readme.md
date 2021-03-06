# Before macOS wipe
- Did you commit and push any changes/branches to your git repositories?
- Did you remember to save all important documents from non-iCloud/Google Drive directories?
- Did you remember to export important data from your local database?
- Did you update [mackup](https://github.com/lra/mackup) to the latest version and ran `mackup backup`?
- Run `./git-dump.sh` and copy the generated `~/Code/git-remote-dump.txt` file to the new computer

# Installation
- Install macOS Command Line Tools by running `xcode-select --install`
- Download ssh keys to have access to git
- Clone this repo and start the installation
```
git clone git@github.com:ivandokov/dotfiles.git ~/.dotfiles && cd ~/.dotfiles
./install
```
- After Google Drive is installed launch it and start syncing so `Apps/Mackup` directory is synced. Then restore preferences by running `mackup restore`
- Clone all repositories by using `./git-clone.sh ~/Downloads/git-remote-dump.txt`
- Restart the computer

# 60Hz monitor
Sometimes macOS limits the external displays to only 30Hz. To fix that use `cscreen`.  
Find the display index with `cscreen -l` and then set the proper refresh rate with 
```bash
cscreen -d 32 -x 2560 -y 1440 -r 60 -s 1
```

---

*Inspired by [Dries Vints](https://github.com/driesvints/dotfiles) and [Freek Van der Herten](https://github.com/freekmurze/dotfiles).*
