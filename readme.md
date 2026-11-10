# Layout

The repository covers macOS and Linux (Arch, in practice Omarchy). Everything
shared sits at the top level, and the two platforms only diverge where they
have to.

```
install              picks the installer for this OS and hands over
install.darwin       Homebrew, Mackup, LaunchAgents, crontab, Rosetta
install.linux        pacman, yay, systemd user timer, chsh
lib/dotfiles.sh      symlink and oh-my-zsh helpers used by both
Brewfile             macOS packages
packages/pacman.txt  Arch packages
packages/aur.txt     Arch packages that live in the AUR
zsh/zshrc            the shared shell config
zsh/zshrc.darwin     Homebrew paths, Herd, Docker Desktop, the launchd agent socket
zsh/zshrc.linux      the ssh-agent, fnm
zsh/custom/          aliases, functions and the theme, loaded by oh-my-zsh
zsh/custom/os/<os>/  the aliases and functions that only work on one platform
bin/push-ssh.sh      copies the SSH identity to another of my machines
systemd/             the Linux equivalent of the dotfiles-sync LaunchAgent
```

`zsh/zshrc` detects the platform into `$DOTFILES_OS`, sources
`zsh/zshrc.$DOTFILES_OS`, and then lets oh-my-zsh load `zsh/custom`.
`zsh/custom/zz-os.zsh` is what pulls in `zsh/custom/os/$DOTFILES_OS/*.zsh`.
oh-my-zsh only globs the top level of `$ZSH_CUSTOM`, so files in that
subdirectory are not picked up by accident on the wrong platform, and the `zz-`
prefix puts the loader last so a platform file can override a shared one.

Two conventions are worth remembering when adding something:

* Reach for oh-my-zsh's own `clipcopy` and `open_command` rather than `pbcopy`
  and `open`. They already resolve to pbcopy, wl-copy, xclip or xdg-open as
  appropriate.
* `ip` is a core utility on Linux, so the function that prints the public
  address is called `myip`. The short name is claimed as an alias on macOS
  only.

# Before a macOS wipe
- Did you commit and push any changes/branches to your git repositories?
- Did you backup all important documents from non-iCloud/Google Drive directories?
- Did you check if all databases are recently exported in `/Users/ivan/Library/Mobile\ Documents/com~apple~CloudDocs/Mackup/mysql`?
- Did you update [mackup](https://github.com/lra/mackup) to the latest version and ran `mackup backup`?

# Installation on macOS
- Install macOS Command Line Tools by running `xcode-select --install`
- Download ssh keys to have access to git
- Clone this repo and start the installation
```
git clone git@github.com:ivandokov/dotfiles.git ~/.dotfiles && cd ~/.dotfiles
./install
```
- In iCloud Drive download `Mackup` directory available offline. Then restore preferences by running `mackup restore`
- Clone all repositories by using `~/.dotfiles/git-clone.sh /Users/ivan/Library/Mobile\ Documents/com~apple~CloudDocs/Mackup/git-remote-dump.txt`
- Import all of the required databases from `/Users/ivan/Library/Mobile\ Documents/com~apple~CloudDocs/Mackup/mysql`
- Restart the computer

# Installation on Omarchy

Omarchy does not run an SSH server out of the box, so start it on the new
machine before anything else:

```
sudo systemctl enable --now sshd
sudo ufw allow 22/tcp && sudo ufw reload
```

Then, from a machine that already has the keys:

```
~/.dotfiles/bin/push-ssh.sh <host>
```

and on the Omarchy machine:

```
git clone git@github.com:ivandokov/dotfiles.git ~/.dotfiles && cd ~/.dotfiles
./install
```

`./install` takes two options there:

* `--dev` also installs PHP, Composer and the MySQL client, which the Laravel
  aliases and the `db` and `opendb` functions need. It is off by default
  because a desktop does not need a web stack. Herd covers this on macOS.
* `--nvim` also points `~/.config/nvim` at this repository. It is off by
  default because Omarchy ships a Neovim config of its own and replacing it is
  a decision rather than an obvious default.

Nothing is deleted. Anything standing where a symlink should go is moved aside
with a `.bak-<timestamp>` suffix.

Mackup, the LaunchAgents, the crontab and the Time Machine exclusions are
macOS only and are skipped. The dotfiles sync runs from a systemd user timer
instead, which `./install` enables.

# Syncing between machines

`sync.sh` keeps the repository identical on every machine. It pulls with rebase, commits
any local changes as `sync from <host>`, and pushes. It runs every 15 minutes, from the
`com.ivan.dotfiles-sync` LaunchAgent on macOS and the `dotfiles-sync.timer` user unit on
Linux, so an edit on one machine shows up on the others within half an hour. Run
`dot sync` to do it right away.

Because it commits everything in the working tree, an unfinished edit left in
`~/.dotfiles` is pushed on the next run like any other change.

Conflicts are not resolved automatically. The script aborts the rebase and retries on the
next run, so fix them by hand in `~/.dotfiles` when `/tmp/dotfiles-sync.out` reports one.
On Linux the same output is in `journalctl --user -u dotfiles-sync`.

# Time Machine exclusions

`tm-exclude.sh` excludes regenerable and already replicated data from Time Machine.
It runs every 15 minutes via the `com.ivan.tm-exclude` LaunchAgent.

There are two kinds of rule in the script. Name rules scan `~/Code`, `~/.paseo` and
`~/.t3` for `node_modules` and Composer `vendor` directories at any depth. Path rules
exclude specific fixed locations: the Apple wallpaper video cache, Docker's VM disk
image, the pnpm and npm caches, and `~/Library/CloudStorage`. Missing roots and paths
are skipped, so the same list works on every machine.

Nothing excluded is the only copy of anything. It is either rebuilt on demand or held
somewhere else. Two consequences are worth knowing. Docker named volumes live inside the
excluded disk image, so anything kept only in a volume is not backed up. Google Drive
content is excluded on the basis that Drive itself holds it.

A few things worth knowing if you ever change it:

* It writes the `com.apple.metadata:com_apple_backup_excludeItem` extended attribute
  directly instead of calling `tmutil addexclusion`. `tmutil` round trips through
  `backupd`, which costs about 11 seconds per call when the backup destination is a
  network share. The direct write takes about 2 milliseconds.
* Directories that already carry the attribute are filtered out inside `find` itself
  with `-xattrname`, so a run with nothing new to do finishes in a couple of seconds.
* There is no depth limit. Package level `node_modules` in a monorepo sit six or seven
  levels deep, so a shallow search finds almost none of them.
* A directory named `vendor` is only excluded when it contains `autoload.php` or a
  `composer` subdirectory. Laravel keeps hand edited overrides in
  `resources/views/vendor` and `resources/lang/vendor`, and published assets in
  `public/vendor`. Those are source and must stay backed up.
* The exclusions are sticky, meaning they live on the directory rather than in a central
  list. Ephemeral worktrees under `~/.paseo` and `~/.t3` therefore need no cleanup. They
  simply take their exclusion with them when they are removed, and new ones are picked up
  within 15 minutes.
* A lock directory prevents two runs from overlapping.

The LaunchAgent is used rather than a cron entry because cron silently skips any run
scheduled while the machine is asleep, which on a laptop is most of them. `StartInterval`
makes launchd run the job once shortly after wake if the interval elapsed during sleep.

## Seeing what is excluded

The System Settings panel will always say "No Excluded Items" for this setup, and that
is expected rather than a fault. Time Machine has two kinds of exclusion. The panel only
lists fixed path exclusions, which live in Time Machine's own preferences and are created
with the `+` button or `tmutil addexclusion -p`. What this setup uses are sticky
exclusions, which live as an extended attribute on the directory itself, follow it if it
moves, and are invisible to that panel.

Use `tm-exclude-list.sh` to see them:

```
./tm-exclude-list.sh              # all of $HOME, about 20 seconds
./tm-exclude-list.sh -q           # quick, only the project roots
./tm-exclude-list.sh -s           # with sizes and a total
./tm-exclude-list.sh ~/some/path  # a specific path
```

It also prints any fixed path and volume exclusions, so it covers all three kinds in one
place. To check a single directory, `tmutil isexcluded <path>` answers directly and is the
same query Time Machine itself uses.

## Installing it

`./install` does this automatically for every plist in `launchagents`. To do it by hand:

```
ln -sfn ~/.dotfiles/launchagents/com.ivan.tm-exclude.plist \
        ~/Library/LaunchAgents/com.ivan.tm-exclude.plist
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.ivan.tm-exclude.plist
```

`RunAtLoad` is set, so it runs once immediately. Check that it worked:

```
launchctl print gui/$(id -u)/com.ivan.tm-exclude | grep -E "state|last exit code|runs"
```

Force a run without waiting for the interval:

```
launchctl kickstart -k gui/$(id -u)/com.ivan.tm-exclude
```

Output goes to `/tmp/tm-exclude.out` and `/tmp/tm-exclude.err`. The script only logs when
it actually excludes something, so an empty file is the normal steady state and does not
mean it is broken.

To remove it:

```
launchctl bootout gui/$(id -u)/com.ivan.tm-exclude
rm ~/Library/LaunchAgents/com.ivan.tm-exclude.plist
```

---

*Inspired by [Dries Vints](https://github.com/driesvints/dotfiles) and [Freek Van der Herten](https://github.com/freekmurze/dotfiles).*
