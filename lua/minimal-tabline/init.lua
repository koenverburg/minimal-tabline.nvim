local M = {}

local fn = vim.fn
local fmt = string.format

local SPACE = " "
local RESET = "%#MTReset#"
local ACTIVE = "%#MTActive#"

local highlight = function(group, properties)
  local fg = properties.fg == nil and "" or "guifg=" .. properties.fg
  local bg = properties.bg == nil and "" or "guibg=" .. properties.bg
  local style = properties.style == nil and "" or "gui=" .. properties.style
  local cmd = table.concat({ "highlight", group, bg, fg, style }, " ")
  vim.cmd(cmd)
end

local colors_keys = {
  TabLine = { fg = "none", bg = "none", style = "none" },
  TabLineSel = { fg = "none", bg = "none", style = "none" },
  TabLineFill = { fg = "none", bg = "none", style = "none" },
  MTReset = { fg = "none", bg = "none", style = "none" },
  MTActive= { fg = "#ffffff", style="underline,bold" },
}

local function minimal(options)
  local line = ""
  local current_tab = fn.tabpagenr()

  for index = 1, fn.tabpagenr "$" do
    local winnumber = fn.tabpagewinnr(index)

    local buffer_list = fn.tabpagebuflist(index)
    local buffer_number = buffer_list[winnumber]
    local buffer_name = fn.bufname(buffer_number)
    local buffer_modified = fn.getbufvar(buffer_number, "&mod")

    local name = fn.fnamemodify(buffer_name, ":t")

    if not options.file_name then
      name = ""
    else
      name = " " .. name
    end

    if options.tab_index then
      name = index .. name
    else
      name = name
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

  local width = fn.winwidth(0) - #line + 20

  return line .. string.rep("━", width)
end

function M.setup(options)
  options = options or {}

  M.options = vim.tbl_deep_extend("force", {
    enabled = true,
    file_name = false,
    tab_index = true,
    pane_count = false,
    modified_sign = true,
    no_name = "[No Name]",
  }, options)

  function _G.minimal_tabline()
    for hl, col in pairs(colors_keys) do
      highlight(hl, col)
    end
    return minimal(M.options)
  end

  if M.options.enabled then
    vim.opt.showtabline = 2
    vim.opt.tabline = "%!v:lua.minimal_tabline()"
  end
end

M.setup()

return M
