-- ~/.config/nvim/lua/config/py_venv.lua
local M = {}
local uv = vim.uv

---@param root_dir string  -- absolute path of project root
---@return string|nil      -- absolute path of the venv, or nil
function M.detect(root_dir)
  ---------------------------------------------------------------------------
  -- 0. If user already activated a venv (e.g. via `poetry shell`)
  ---------------------------------------------------------------------------
  local active = os.getenv("VIRTUAL_ENV")
  if active and #active > 0 then
    return active
  end

  ---------------------------------------------------------------------------
  -- 1. Poetry project: ask Poetry for its canonical venv path
  ---------------------------------------------------------------------------
  if vim.fs.find("pyproject.toml", { path = root_dir, upward = false })[1] then
    local handle = io.popen("poetry env info -p 2>/dev/null")
    if handle then
      local result = handle:read("*a"):gsub("%s+$", "")
      handle:close()
      if #result > 0 and uv.fs_stat(result) then
        return result
      end
    end
  end

  ---------------------------------------------------------------------------
  -- 2. Conventional folders (.venv/ or venv/) under the project root
  ---------------------------------------------------------------------------
  for _, dir in ipairs({ ".venv", "venv" }) do
    local candidate = vim.fs.joinpath(root_dir, dir)
    if uv.fs_stat(candidate) then
      return candidate
    end
  end
end

return M
