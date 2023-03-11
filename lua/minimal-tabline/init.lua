local M = {}

local fmt = string.format
local fn,api = vim.fn, vim.api

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
  MTActive = { fg = "#ffffff", style = "underline,bold" },
}

local function calc_win_width()
  local width = 0
  local pages = {}

  local current_tab = fn.tabpagenr()
  local tabinfo = vim.fn.gettabinfo()

  for _, tab in pairs(tabinfo) do
    pages[tab.tabnr] = {}
    for _, winid in pairs(tab.windows) do
      local bufnr = fn.winbufnr(winid)
      local name = api.nvim_buf_get_name(bufnr)

      if name ~= '' then
        pages[tab.tabnr][winid] = {
          name = name,
          bufnr = bufnr,
          width = api.nvim_win_get_width(winid),
          height = api.nvim_win_get_height(winid)
        }
      end
    end
  end

  for _, wins in pairs(pages[current_tab]) do
    width = width + wins.width + 1
  end

  return width
end

local function minimal(options)
  local line = ""
  local parts = {}
  local clean_parts = {}

  for index = 1, #vim.api.nvim_list_tabpages() do
    local win = fn.tabpagewinnr(index)
    local buffer_list = fn.tabpagebuflist(index)
    local current_tab = fn.tabpagenr()

    local buffer_number = buffer_list[win]
    local buffer_name = fn.bufname(buffer_number)
    local buffer_modified = fn.getbufvar(buffer_number, "&mod")

    local name = fn.fnamemodify(buffer_name, ":t")

    table.insert(parts, SPACE)
    table.insert(clean_parts, SPACE)

    if buffer_name ~= "" then
      if index == current_tab then
        table.insert(parts, ACTIVE)
      end
    else
      table.insert(parts, RESET)
    end

    if options.tab_index then
      table.insert(parts, index)
      table.insert(clean_parts, index)
    end

    if options.tab_index and options.file_name then
      table.insert(parts, SPACE)

      table.insert(clean_parts, SPACE)
    end

    if options.file_name then
      table.insert(parts, name)

      table.insert(clean_parts, name)
    end

    if options.modified_sign and buffer_modified == 1 then
      table.insert(parts, RESET)
      table.insert(parts, SPACE)
      table.insert(parts, "●")

      table.insert(clean_parts, SPACE)
      table.insert(clean_parts, "x")
    end

    if options.pane_count and #buffer_list > 1 then
      table.insert(parts, SPACE)
      table.insert(parts, fmt("(%s)", #buffer_list))

      table.insert(clean_parts, SPACE)
      table.insert(clean_parts, "xxx")
    end

    table.insert(parts, RESET)
    table.insert(parts, SPACE)

    table.insert(clean_parts, SPACE)

    line = table.concat(parts, "")
  end

  line = line

  local winwidth = calc_win_width()
  local offset = #table.concat(clean_parts, "") + 2
  local width = winwidth - offset

  return line .. string.rep("━", width) .. SPACE
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
