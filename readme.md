# Before macOS wipe
- Did you commit and push any changes/branches to your git repositories?
- Did you remember to save all important documents from non-iCloud/Google Drive directories?
- Did you remember to export important data from your local database?
- Did you update [mackup](https://github.com/lra/mackup) to the latest version and ran `mackup backup`?

# Installation
- Install macOS Command Line Tools by running `xcode-select --install`
- Download ssh keys to have access to git
- Clone this repo and start the installation
```
git clone git@github.com:ivandokov/dotfiles.git ~/.dotfiles && cd ~/.dotfiles
./install
```
- In iCloud Drive download `Mackup` directory available offline. Then restore preferences by running `mackup restore`
- Clone all repositories by using `~/.dotfiles/git-clone.sh /Users/ivan/Library/Mobile\ Documents/com~apple~CloudDocs/Mackup/git-remote-dump.txt`
- Restart the computer

---

*Inspired by [Dries Vints](https://github.com/driesvints/dotfiles) and [Freek Van der Herten](https://github.com/freekmurze/dotfiles).*
