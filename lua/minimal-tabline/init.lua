local M = {}

require("colorbuddy").setup()
local c = require("colorbuddy.color").colors
local s = require("colorbuddy.style").styles
local Group = require("colorbuddy.group").Group

local fn = vim.fn
local fmt = string.format

local SPACE = " "
local RESET = "%#MTReset#"
local ACTIVE = "%#MTActive#"
local INACTIVE = "%#MTInactive#"

local function minimal(options)
  local line = ""
  local current_tab = fn.tabpagenr()

  for index = 1, fn.tabpagenr "$" do
    local winnumber       = fn.tabpagewinnr(index)

    local buffer_list     = fn.tabpagebuflist(index)
    local buffer_number   = buffer_list[winnumber]
    local buffer_name     = fn.bufname(buffer_number)
    local buffer_modified = fn.getbufvar(buffer_number, "&mod")

    line = line .. "%" .. index .. "T"
    local name = fn.fnamemodify(buffer_name, ":t")

    if not options.file_name then
      name = ""
    end

    if options.tab_index then
      name = index .. SPACE .. name
    else
      name = SPACE .. name
    end

    if options.modified_sign and buffer_modified == 1 then
      name = name .. SPACE .. "●"
    end

    if options.pane_count and #buffer_list > 1 then
      name = name .. SPACE .. fmt("(%s)", #buffer_list)
    end

    if buffer_name ~= "" then
      if index == current_tab then
        line = line .. ACTIVE .. name .. RESET .. SPACE
      else
        line = line .. name .. SPACE
      end
    else
      line = line .. options.no_name .. SPACE
    end
  end

  line = line
  return line
end

function M.setup(options)
  options = options or {}

  M.options = vim.tbl_deep_extend("force", {
    enable = true,
    file_name = true,
    tab_index = true,
    pane_count = true,
    modified_sign = true,
    no_name = "[No Name]",
  }, options)

  function _G.minimal_tabline()
    return minimal(M.options)
  end

  if M.options.enable then
    vim.opt.showtabline = 2
    vim.opt.tabline = "%!v:lua.minimal_tabline()"
  end
end

M.setup()

vim.cmd [[ highlight TabLine     cterm=none gui=none ]]
vim.cmd [[ highlight TabLineSel  cterm=none gui=none ]]
vim.cmd [[ highlight TabLineFill cterm=none gui=none ]]

Group.new("MTActive", c.white:dark(), nil, s.bold + s.underline)
Group.new("MTInactive", c.white:dark(), nil, s.NONE)
Group.new("MTReset", nil, nil, nil)

Group.new("TabLineFill", nil, nil, nil)
Group.new("TabLine", nil, nil, nil)
Group.new("TabLineSel", nil, nil, nil)

return M
