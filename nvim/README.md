# Neovim for PHP, Laravel, Livewire, Alpine and TypeScript

This config is built on [LazyVim](https://lazyvim.org). LazyVim provides a well maintained base (file finder, git, completion, language servers), and the files in `lua/` add the PHP/Laravel parts on top.

## First day

1. Open a project from its root folder: `cd ~/Code/my-project && nvim`
2. Do the built in lesson once. It takes about 30 minutes and teaches the keys everything else builds on: type `:Tutor` and press Enter.
3. Press `Space` and wait. A menu shows every shortcut, grouped by topic. This is the most useful key while you learn.

`Space` is called the **leader** key. In this document `Space f r` means: press Space, then f, then r (one after another, not together).

### The one concept that is different from PhpStorm

Neovim has **modes**. You start in *Normal* mode, where keys are commands (`dd` deletes a line, `u` undoes). Press `i` to go to *Insert* mode and type text like in PhpStorm. Press `Esc` to go back to Normal mode. Press `v` for *Visual* mode to select text.

| Action | Keys |
| --- | --- |
| Save | `Ctrl+s` (or `:w` Enter) |
| Quit | `Space q q` (or `:q` Enter) |
| Undo / Redo | `u` / `Ctrl+r` |
| Start typing | `i` (before cursor), `a` (after), `o` (new line below) |
| Back to Normal mode | `Esc` |
| Jump anywhere on screen | `s` then type 2 characters, then the label that appears |

## PhpStorm to Neovim

### Navigation

| PhpStorm | Neovim |
| --- | --- |
| Search Everywhere / Go to File (Shift Shift, Cmd+Shift+O) | `Space Space` |
| Recent Files (Cmd+E) | `Space f r`, open files: `Space ,` |
| Find in Files (Cmd+Shift+F) | `Space /` |
| Replace in Files (Cmd+Shift+R) | `Space s r` |
| Go to Symbol (Cmd+Alt+O) | `Space s S` |
| File Structure (Cmd+F12) | `Space s s`, side panel: `Space c s` |
| Project tool window (Cmd+1) | `Space e` |
| Recent Projects | `Space f p` |
| Back / Forward (Cmd+[ / Cmd+]) | `Ctrl+o` / `Ctrl+i` |
| Switch editor tabs | `Shift+h` / `Shift+l` |
| Close tab (Cmd+W) | `Space b d` |
| Split right / below | `Space \|` / `Space -` |
| Move between splits and tmux panes | `Ctrl+h` `Ctrl+j` `Ctrl+k` `Ctrl+l` |
| Terminal (Alt+F12) | `Ctrl+/` |
| Search all shortcuts | `Space s k` |

### Code intelligence

| PhpStorm | Neovim |
| --- | --- |
| Go to Declaration (Cmd+B, Cmd+click) | `gd` |
| Find Usages (Alt+F7) | `gr` |
| Go to Implementation (Cmd+Alt+B) | `gI` |
| Go to Type Declaration | `gy` |
| Quick Documentation (F1) | `K` |
| Parameter Info (Cmd+P) | `gK`, in Insert mode `Ctrl+k` |
| Show Intention Actions (Alt+Enter) | `Space c a` |
| Rename (Shift+F6) | `Space c r` |
| Refactor This (Ctrl+T) | `Space r s` |
| Extract Method / Variable | select code with `v`, then `Space r f` / `Space r x` |
| Reformat Code (Cmd+Alt+L) | `Space c f` |
| Next / previous problem (F2) | `]d` / `[d` (errors only: `]e` / `[e`) |
| Problem details under cursor | `Space c d` |
| Problems tool window | `Space x x` |
| Comment line (Cmd+/) | `gcc`, selection: `gc` |
| Move line up / down | `Alt+k` / `Alt+j` |
| Duplicate line / Delete line | `yyp` / `dd` |

Completion pops up while typing. `Enter` accepts the highlighted item, `Ctrl+n` / `Ctrl+p` move through the list, `Ctrl+Space` opens it manually.

### AI

| What | Keys |
| --- | --- |
| Open Claude Code next to the code | `Space a c` |
| Send selection to Claude | select with `v`, then `Space a s` |
| Add current file to Claude's context | `Space a b` |
| Accept / reject a change Claude proposes | `Space a a` / `Space a d` |

Claude Code running in a separate tmux or herdr pane can also connect to this Neovim: type `/ide` in Claude and pick Neovim. Claude then sees the file and selection you are on, and shows its edits as diffs in Neovim.

### Git

| PhpStorm | Neovim |
| --- | --- |
| Commit window, push, pull, branches, stash | `Space g g` (lazygit, press `?` inside for help) |
| Diff of all local changes | `Space g v` (again to close) |
| Show History for file / selection | `Space g V` |
| Annotate with Git Blame | `Space g h B`, one line: `Space g h b` |
| Next / previous change | `]h` / `[h` |
| Show diff of change under cursor | `Space g h p` |
| Rollback change under cursor | `Space g h r` |
| Stage change under cursor | `Space g h s` |
| Open on GitHub | `Space g B` |
| Pull requests / issues (needs `gh`) | `Space g p` / `Space g i` |

**Merge conflicts**: run `Space g v` during a merge or rebase. It opens a 3 way view. Jump between conflicts with `]x` / `[x`, then take `Space c o` (ours), `Space c t` (theirs), `Space c a` (all) or `d x` (none).

### Laravel and Livewire

| What | Keys |
| --- | --- |
| Go to the file under the cursor | `gf` |
| Everything Laravel (one picker) | `Space l l` |
| Artisan commands | `Space l a` |
| Routes (jumps to the controller) | `Space l r` |
| `artisan make:*` | `Space l m` |
| Related files (model, controller, migration, factory ...) | `Space l R` |
| Where is this Blade view used | `Space l v` |
| Tinker | `Space l k` |
| Long running commands (serve, vite, queue) in tabs | `Space l u` |

`gf` understands:

* `<livewire:counter />`, `<livewire:pages::settings.profile />`, `@livewire('counter')`, including Livewire 4 single file components (`⚡counter.blade.php`)
* `route('invoice.show')` (opens the controller or Livewire component)
* `view('livewire.invoice-list')`, `@include(...)`, `@extends(...)`, `<x-layouts.app>`
* `config('app.name')`, `env('APP_KEY')`, `__('messages.welcome')`

Completion knows your view names, route names, config keys, `.env` keys, Blade components and Eloquent column names in `where('...')`.

Blade files get HTML, Emmet (`div.card>ul>li*3` then accept) and Tailwind class completion. JavaScript inside Alpine attributes (`x-data`, `@click`, `:class`) and `wire:` attributes is highlighted as JavaScript.

### Tests (Pest and PHPUnit)

| What | Keys |
| --- | --- |
| Run test under cursor | `Space t r` |
| Run current file | `Space t t` |
| Run all tests | `Space t T` |
| Run last test again | `Space t l` |
| Show output | `Space t o` |
| Test tree panel | `Space t s` |

### Database

`Space D` opens a database browser (like PhpStorm's Database tool window). Add a connection with a URL such as `sqlite:database/database.sqlite` or `mysql://root@127.0.0.1:3306/mydb`. MySQL needs the `mysql` client installed (`brew install mysql-client`).

## How formatting works

Files are only formatted on save when the project opted into a formatter:

* PHP: Laravel Pint, when the project has `vendor/bin/pint` (uses the project's `pint.json`)
* JS, TS, CSS, JSON, YAML: Prettier, when the project has a Prettier config file
* JS and TS: ESLint fixes, when the project uses ESLint
* Blade: never

Older projects without Pint or Prettier are never reformatted. Toggle format on save with `Space u f`.

## PHP language servers

Intelephense does completion, go to definition, find usages, hover and diagnostics. The free version has no rename, go to implementation or code actions, so phpactor is started next to it only for those features. If you buy an Intelephense licence (intelephense.com), put the key in `~/intelephense/licence.txt` and restart Neovim. phpactor is then no longer started.

In a project that contains a `.phpactor.json` file, phpactor asks once whether you trust it (the file can run code). Answer "Yes" for your own projects.

### Eloquent models (recommended per project)

Intelephense cannot see Eloquent magic (`$user->email`, `User::where(...)`) on its own. PhpStorm's Laravel Idea did that for you. The standard fix is laravel-ide-helper:

```sh
composer require --dev barryvdh/laravel-ide-helper
php artisan ide-helper:generate
php artisan ide-helper:models --nowrite
php artisan ide-helper:meta
```

Add `_ide_helper.php`, `_ide_helper_models.php` and `.phpstorm.meta.php` to `.gitignore` if the team doesn't commit them. Rerun `ide-helper:models --nowrite` after migrations.

## Where things are

| File | What it does |
| --- | --- |
| `lua/config/lazy.lua` | Which LazyVim extras are enabled |
| `lua/config/options.lua` | Editor options |
| `lua/config/keymaps.lua` | Extra shortcuts (`gf`, `Space f y` copies the file path) |
| `lua/plugins/php.lua` | Intelephense, phpactor, Pint, PHPStan |
| `lua/plugins/laravel.lua` | laravel.nvim, blade-nav, Laravel completion |
| `lua/plugins/web.lua` | HTML, Emmet, TypeScript and formatting rules |
| `lua/plugins/git.lua` | Diff view |
| `lua/plugins/tmux.lua` | `Ctrl+h/j/k/l` across tmux panes |
| `lua/user/laravel_gf.lua` | The Laravel aware `gf` |

Useful commands: `:Lazy` (plugins, press `U` to update), `:Mason` (language servers), `:LazyExtras` (optional feature packs), `:checkhealth` (diagnose problems), `Space c l` (language servers and what they are attached to).

## Terminal notes

* Ghostty: left Option works as Alt (`macos-option-as-alt = left` in `~/.config/ghostty/config`). Needed for `Alt+j`, `Alt+]` and your tmux `Alt+[` shortcuts.
* tmux: `~/.tmux.conf` enables true colour and curly underlines for errors. Reload with prefix then `R`.
* herdr: everything works, only `Ctrl+h/j/k/l` pane switching is tmux specific.
