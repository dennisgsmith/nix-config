vim.api.nvim_create_user_command('H', function(table)
  vim.cmd('help ' .. table.args .. ' | only')
end, { desc = 'Open [H]elp in new tab', nargs = 1 })

vim.api.nvim_create_user_command('HtmlTablesToMarkdown', function(opts)
  local start_line = opts.range > 0 and opts.line1 or 1
  local end_line = opts.range > 0 and opts.line2 or vim.api.nvim_buf_line_count(0)

  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local text = table.concat(lines, '\n')

  local function clean_cell(s)
    s = s:gsub('\n', ' ')
    s = s:gsub('<br%s*/?>', ' ')
    s = s:gsub('<[^>]+>', '')
    s = s:gsub('&nbsp;', ' ')
    s = s:gsub('&amp;', '&')
    s = s:gsub('&lt;', '<')
    s = s:gsub('&gt;', '>')
    s = s:gsub('&quot;', '"')
    s = s:gsub('&#39;', "'")
    s = s:gsub('|', '\\|')
    s = s:gsub('%s+', ' ')
    s = s:gsub('^%s+', '')
    s = s:gsub('%s+$', '')
    return s
  end

  local function parse_cells(row)
    local cells = {}

    for _tag, attrs, content in row:gmatch '<([Tt][HhDd])([^>]*)>(.-)</[Tt][HhDd]>' do
      local colspan = tonumber(attrs:match '[Cc][Oo][Ll][Ss][Pp][Aa][Nn]%s*=%s*[\'"]?(%d+)') or 1
      table.insert(cells, clean_cell(content))

      for _ = 2, colspan do
        table.insert(cells, '')
      end
    end

    return cells
  end

  local function html_table_to_markdown(html)
    local rows = {}

    for row in html:gmatch '<[Tt][Rr][^>]*>(.-)</[Tt][Rr]>' do
      local cells = parse_cells(row)
      if #cells > 0 then
        table.insert(rows, cells)
      end
    end

    if #rows == 0 then
      return html
    end

    local max_cols = 0
    for _, row in ipairs(rows) do
      max_cols = math.max(max_cols, #row)
    end

    for _, row in ipairs(rows) do
      while #row < max_cols do
        table.insert(row, '')
      end
    end

    local out = {}

    local function md_row(row)
      return '| ' .. table.concat(row, ' | ') .. ' |'
    end

    table.insert(out, md_row(rows[1]))

    local sep = {}
    for _ = 1, max_cols do
      table.insert(sep, '---')
    end
    table.insert(out, md_row(sep))

    for i = 2, #rows do
      table.insert(out, md_row(rows[i]))
    end

    return table.concat(out, '\n')
  end

  local result = {}
  local pos = 1
  local lower = text:lower()

  while true do
    local table_start = lower:find('<table', pos, true)

    if not table_start then
      table.insert(result, text:sub(pos))
      break
    end

    local table_end_start, table_end_finish = lower:find('</table>', table_start, true)

    if not table_end_start then
      table.insert(result, text:sub(pos))
      break
    end

    table.insert(result, text:sub(pos, table_start - 1))

    local html_table = text:sub(table_start, table_end_finish)
    table.insert(result, html_table_to_markdown(html_table))

    pos = table_end_finish + 1
  end

  local converted_text = table.concat(result)
  local new_lines = vim.split(converted_text, '\n', { plain = true })

  vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, new_lines)
end, {
  range = true,
  desc = 'Convert only HTML table blocks to Markdown pipe tables',
})
