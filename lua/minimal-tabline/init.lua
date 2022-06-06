local M = {}

local fn = vim.fn
local fmt = string.format

local SPACE    = " "
local RESET    = "%#MTReset#"
local ACTIVE   = "%#MTActive#"

vim.cmd [[ hi MTActive    gui=UnderLinebold ctermfg=none ctermbg=none ]]
vim.cmd [[ hi MTReset     gui=none          ctermfg=none ctermbg=none ]]

vim.cmd [[ hi TabLine     cterm=none ctermbg=none gui=none ]]
vim.cmd [[ hi TabLineSel  cterm=none ctermbg=none gui=none ]]
vim.cmd [[ hi TabLineFill cterm=none ctermbg=none gui=none ]]

local function minimal(options)
  local line = ""
  local current_tab = fn.tabpagenr()

  for index = 1, fn.tabpagenr "$" do
    local winnumber       = fn.tabpagewinnr(index)

    local buffer_list     = fn.tabpagebuflist(index)
    local buffer_number   = buffer_list[winnumber]
    local buffer_name     = fn.bufname(buffer_number)
    local buffer_modified = fn.getbufvar(buffer_number, "&mod")

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
      line = line .. ACTIVE .. options.no_name .. RESET .. SPACE
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

return M
