vim.pack.add {
  { src = 'https://github.com/L3MON4D3/LuaSnip', version = vim.version.range '2.0' },
}

vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    if ev.data.spec.name ~= 'LuaSnip' then
      return
    end

    if ev.data.kind ~= 'install' and ev.data.kind ~= 'update' then
      return
    end

    vim.system({ 'make', 'install_jsregexp' }, { cwd = ev.data.path }, function(res)
      if res.code ~= 0 then
        vim.schedule(function()
          vim.notify('LuaSnip build failed:\n' .. ((res.stderr and res.stderr ~= '') and res.stderr or (res.stdout or '')), vim.log.levels.ERROR)
        end)
      end
    end)
  end,
})
