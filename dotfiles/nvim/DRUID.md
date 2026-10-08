# Crow / druid

Run `druid` in a terminal while crow is connected. Restart Neovim to load the
commands. Replies (including identity, version and printed scripts) appear in
the druid terminal. Sending is asynchronous; connection failures appear as
Neovim notifications. `websocat` is already in the shared Home Manager packages.

Leader is Space. These mappings leave the existing code-action mapping (`ca`)
and debugger mappings intact:

| Key | Mode | Command | Action |
| --- | --- | --- | --- |
| `<leader>cl` | Normal | `:DruidSend` | Send current line |
| `<leader>cs` | Visual | `:'<,'>DruidSend` | Evaluate selected **whole lines** as one Lua block |
| `<leader>cb` | Normal | `:DruidSendBuffer` | Evaluate the buffer, including unsaved edits |
| `<leader>ce` | Normal | `:DruidEnvironment` | Choose an environment command |

`:DruidSend print(time())` sends literal text. `:10,20DruidSend` sends a range.
Ranges and the buffer use crow's triple-backtick block delimiters; evaluating
them does not install a boot script or write flash.

All [environment commands](https://monome.org/docs/crow/technical/#environment-commands)
are also available directly:

| Command | Action |
| --- | --- |
| `:DruidStartScript` | Start receiving a script |
| `:DruidExecuteScript` | Send the current buffer to crow and run it without saving |
| `:DruidWriteScript` | Send the current buffer to crow, save it to flash, and run it |
| `:DruidClearScript` | Clear the saved user script |
| `:DruidFirst` | Restore First as the boot script and run it |
| `:DruidPrintScript` | Print the saved script |
| `:DruidBootloader` | Enter the firmware bootloader |
| `:DruidReset` | Reboot crow, resetting USB |
| `:DruidKill` | Restart Lua without running the user script |
| `:DruidIdentity` | Print the serial number |
| `:DruidVersion` | Print the firmware version |

`:DruidExecuteScript` sends the current buffer to crow and runs it without
saving. `:DruidWriteScript` sends the current buffer, saves it to flash, and
runs it. Both use crow's start, transfer, and finish sequence and accept scripts
up to 8 KiB. `:DruidStartScript` is available for manually entering crow's
script reception mode; use the buffer commands for normal script execution and
saving.

The default endpoint is `ws://localhost:6666`. Override it with
`vim.g.druid_url` if druid is hosted elsewhere.

## Crow Lua completion and documentation

After any successful Druid command in a Neovim session, entering a Lua buffer
checks whether druid is reachable. When it is, Neovim starts a crow-specific
Lua language server for that buffer. Type `output[1].` or `clock.` for
completion, press `K` for API docs, and `<C-k>` for function signatures. Crow
metadata follows the scripting API and stays separate from the regular Lua
language-server workspace. If druid stops, the crow server detaches when you
next enter the buffer; the ordinary Lua server is restored if it was attached.
