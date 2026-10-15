-- `gf` (go to file) for Laravel projects. Tries, in order:
--   1. Livewire tags: <livewire:counter />, <livewire:pages::settings.profile />, @livewire('counter')
--      Supports Livewire 4 single/multi-file components (⚡name.blade.php) and
--      class based components (app/Livewire/Counter.php).
--   2. route('name') / to_route('name'): jumps to the route's controller (laravel.nvim).
--   3. blade-nav.nvim: <x-components>, @include, @extends, view(), config(), __() ...
--   4. Vim's normal `gf`.

local M = {}

--- Text captured by `pattern` when the cursor is inside the match.
---@param pattern string Lua pattern with one capture
---@return string|nil
local function match_under_cursor(pattern)
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2] + 1
  local init = 1
  while true do
    local s, e, capture = line:find(pattern, init)
    if not s then
      return nil
    end
    if col >= s and col <= e then
      return capture
    end
    init = e + 1
  end
end

local function livewire_under_cursor()
  return match_under_cursor("<livewire:([%w%-%._:]+)")
    or match_under_cursor("@livewire%(%s*['\"]([^'\"]+)['\"]")
    or match_under_cursor("Livewire::mount%(%s*['\"]([^'\"]+)['\"]")
end

local function route_under_cursor()
  return match_under_cursor("route%(%s*['\"]([^'\"]+)['\"]")
end

---@param s string kebab-case
local function pascal(s)
  return (s:gsub("^%l", string.upper):gsub("%-(%w)", string.upper))
end

--- Candidate files for a Livewire component name, most likely first.
---@param root string
---@param name string e.g. "counter", "admin.user-list", "pages::settings.profile"
local function livewire_candidates(root, name)
  local namespace, rest = name:match("^([%w%-_]+)::(.+)$")
  rest = rest or name
  local bases = namespace and { "resources/views/" .. namespace }
    or { "resources/views/components", "resources/views/livewire" }

  local rel = rest:gsub("%.", "/")
  local dir, leaf = rel:match("^(.*)/([^/]+)$")
  dir = dir and (dir .. "/") or ""
  leaf = leaf or rel

  local candidates = {}
  for _, base in ipairs(bases) do
    local b = root .. "/" .. base .. "/"
    vim.list_extend(candidates, {
      b .. dir .. "⚡" .. leaf .. ".blade.php", -- Livewire 4 single-file component
      b .. rel .. "/⚡" .. leaf .. ".blade.php", -- Livewire 4 multi-file component
      b .. rel .. "/" .. leaf .. ".php",
      b .. rel .. ".blade.php", -- no emoji prefix
    })
  end
  if not namespace then
    local class = table.concat(vim.tbl_map(pascal, vim.split(rest, ".", { plain = true })), "/")
    table.insert(candidates, root .. "/app/Livewire/" .. class .. ".php")
    table.insert(candidates, root .. "/app/Http/Livewire/" .. class .. ".php")
  end
  return candidates
end

local function open_livewire(name)
  local root = vim.fs.root(0, "artisan")
  if not root then
    return false
  end
  for _, path in ipairs(livewire_candidates(root, name)) do
    if vim.uv.fs_stat(path) then
      vim.cmd.edit(vim.fn.fnameescape(path))
      return true
    end
  end
  return false
end

local function open_route(name)
  if not (_G.Laravel and Laravel.app:isActive()) then
    return false
  end
  require("nio").run(function()
    local routes = require("laravel.core.app"):make("laravel.loaders.routes_loader"):load()
    for _, route in ipairs(routes or {}) do
      if route.name == name then
        return require("laravel.pickers.common.actions").open_route(route)
      end
    end
    vim.schedule(function()
      vim.notify("Route not found: " .. name, vim.log.levels.WARN)
    end)
  end)
  return true
end

local function native_gf()
  local ok, err = pcall(vim.cmd.normal, { "gf", bang = true })
  if not ok then
    vim.notify((tostring(err):gsub("^Vim%(normal%):", "")), vim.log.levels.WARN)
  end
end

local busy = false

function M.gf()
  -- blade-nav falls back to the global `gf` mapping (this function) when it
  -- can't resolve anything; use Vim's gf in that case instead of looping.
  if busy then
    return native_gf()
  end
  busy = true
  local ok, err = pcall(function()
    local livewire = livewire_under_cursor()
    if livewire and open_livewire(livewire) then
      return
    end
    local route = route_under_cursor()
    if route and open_route(route) then
      return
    end
    local ft = vim.bo.filetype
    if (ft == "blade" or ft == "php") and package.loaded["blade-nav"] and (vim.g.blade_nav or {}).enable ~= false then
      return require("blade-nav.integrations.gf").gf()
    end
    native_gf()
  end)
  busy = false
  if not ok then
    vim.notify(tostring(err), vim.log.levels.ERROR)
  end
end

return M
