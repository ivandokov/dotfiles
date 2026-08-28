# Before macOS wipe
- Did you commit and push any changes/branches to your git repositories?
- Did you backup all important documents from non-iCloud/Google Drive directories?
- Did you check if all databases are recently exported in `/Users/ivan/Library/Mobile\ Documents/com~apple~CloudDocs/Mackup/mysql`?
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
- Import all of the required databases from `/Users/ivan/Library/Mobile\ Documents/com~apple~CloudDocs/Mackup/mysql`
- Restart the computer

# Time Machine exclusions

`tm-exclude-node-modules.sh` walks `~/Code`, `~/.paseo` and `~/.t3` and excludes every
`node_modules` directory and every Composer `vendor` directory from Time Machine.
It runs every 15 minutes via the `com.ivan.tm-exclude-node-modules` LaunchAgent.

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

Use `tm-exclusions.sh` to see them:

```
./tm-exclusions.sh              # the usual project roots
./tm-exclusions.sh -s           # with sizes and a total
./tm-exclusions.sh -a           # scan all of $HOME, slower
./tm-exclusions.sh ~/some/path  # scan a specific path
```

It also prints any fixed path and volume exclusions, so it covers all three kinds in one
place. To check a single directory, `tmutil isexcluded <path>` answers directly and is the
same query Time Machine itself uses.

## Installing it

`./install` does this automatically for every plist in `launchagents`. To do it by hand:

```
ln -sfn ~/.dotfiles/launchagents/com.ivan.tm-exclude-node-modules.plist \
        ~/Library/LaunchAgents/com.ivan.tm-exclude-node-modules.plist
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.ivan.tm-exclude-node-modules.plist
```

`RunAtLoad` is set, so it runs once immediately. Check that it worked:

```
launchctl print gui/$(id -u)/com.ivan.tm-exclude-node-modules | grep -E "state|last exit code|runs"
```

Force a run without waiting for the interval:

```
launchctl kickstart -k gui/$(id -u)/com.ivan.tm-exclude-node-modules
```

Output goes to `/tmp/tm-exclude-node-modules.out` and `/tmp/tm-exclude-node-modules.err`.
The script only logs when it actually excludes something, so an empty file is the normal
steady state and does not mean it is broken.

To remove it:

```
launchctl bootout gui/$(id -u)/com.ivan.tm-exclude-node-modules
rm ~/Library/LaunchAgents/com.ivan.tm-exclude-node-modules.plist
```

---

*Inspired by [Dries Vints](https://github.com/driesvints/dotfiles) and [Freek Van der Herten](https://github.com/freekmurze/dotfiles).*
