vim.pack.add {
  { src = 'https://github.com/nvim-mini/mini.statusline' },
  { src = 'https://github.com/echasnovski/mini.icons' },
}

local statusline = require 'mini.statusline'

local function section_location_percent(args)
  if statusline.is_truncated(args.trunc_width) then
    return '%l│%2v│%P'
  end

  return '%l|%L│%2v|%-2{virtcol("$") - 1}│%P'
end

statusline.setup {
  content = {
    active = function()
      local mode, mode_hl = statusline.section_mode { trunc_width = 120 }
      local git = statusline.section_git { trunc_width = 40 }
      local diff = statusline.section_diff { trunc_width = 75 }
      local diagnostics = statusline.section_diagnostics { trunc_width = 75 }
      local lsp = statusline.section_lsp { trunc_width = 75 }
      local filename = statusline.section_filename { trunc_width = 140 }
      local fileinfo = statusline.section_fileinfo { trunc_width = 120 }
      local location = section_location_percent { trunc_width = 75 }
      local search = statusline.section_searchcount { trunc_width = 75 }

      return statusline.combine_groups {
        { hl = mode_hl, strings = { mode } },
        { hl = 'MiniStatuslineDevinfo', strings = { git, diff, diagnostics, lsp } },
        '%<',
        { hl = 'MiniStatuslineFilename', strings = { filename } },
        '%=',
        { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
        { hl = mode_hl, strings = { search, location } },
      }
    end,
  },
}
