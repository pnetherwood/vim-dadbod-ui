if exists('g:loaded_dbui')
  finish
endif
let g:loaded_dbui = 1

let g:dbui_winwidth = get(g:, 'db_ui_winwidth', 40)
let g:dbui_win_position = get(g:, 'db_ui_win_position', 'left')
let g:dbui_default_query = get(g:, 'db_ui_default_query', 'SELECT * from "{table}" LIMIT 200;')
let g:dbui_save_location = get(g:, 'db_ui_save_location', '~/.local/share/db_ui')
let g:dbui_dotenv_variable_prefix = get(g:, 'db_ui_dotenv_variable_prefix', 'DB_UI_')
let g:dbui_env_variable_url = get(g:, 'db_ui_env_variable_url', 'DBUI_URL')
let g:dbui_env_variable_name = get(g:, 'db_ui_env_variable_name', 'DBUI_NAME')
let g:dbui_disable_mappings = get(g:, 'db_ui_disable_mappings', 0)
let g:dbui_table_helpers = get(g:, 'db_ui_table_helpers', {})
let g:dbui_auto_execute_table_helpers = get(g:, 'db_ui_auto_execute_table_helpers', 0)
let g:dbui_show_help = get(g:, 'db_ui_show_help', 1)
let g:dbui_use_nerd_fonts = get(g:, 'db_ui_use_nerd_fonts', 0)
let g:dbui_execute_on_save = get(g:, 'db_ui_execute_on_save', 1)
let s:dbui_icons = get(g:, 'db_ui_icons', {})
let s:expanded_icon = get(s:dbui_icons, 'expanded', '▾')
let s:collapsed_icon = get(s:dbui_icons, 'collapsed', '▸')
let s:expanded_icons = {}
let s:collapsed_icons = {}

if type(s:expanded_icon) !=? type('')
  let s:expanded_icons = s:expanded_icon
  let s:expanded_icon = '▾'
else
  silent! call remove(s:dbui_icons, 'expanded')
endif

if type(s:collapsed_icon) !=? type('')
  let s:collapsed_icons = s:collapsed_icon
  let s:collapsed_icon = '▸'
else
  silent! call remove(s:dbui_icons, 'collapsed')
endif

let g:dbui_icons = {
      \ 'expanded': {
      \   'db': s:expanded_icon,
      \   'buffers': s:expanded_icon,
      \   'saved_queries': s:expanded_icon,
      \   'schemas': s:expanded_icon,
      \   'schema': s:expanded_icon,
      \   'tables': s:expanded_icon,
      \   'table': s:expanded_icon,
      \ },
      \ 'collapsed': {
      \   'db': s:collapsed_icon,
      \   'buffers': s:collapsed_icon,
      \   'saved_queries': s:collapsed_icon,
      \   'schemas': s:collapsed_icon,
      \   'schema': s:collapsed_icon,
      \   'tables': s:collapsed_icon,
      \   'table': s:collapsed_icon,
      \ },
      \ 'saved_query': '*',
      \ 'new_query': '+',
      \ 'tables': '~',
      \ 'buffers': '»',
      \ 'add_connection': '[+]',
      \ 'connection_ok': '✓',
      \ 'connection_error': '✕',
      \ }

if g:dbui_use_nerd_fonts
  let g:dbui_icons = {
        \ 'expanded': {
        \   'db': s:expanded_icon.' ',
        \   'buffers': s:expanded_icon.' ',
        \   'saved_queries': s:expanded_icon.' ',
        \   'schemas': s:expanded_icon.' ',
        \   'schema': s:expanded_icon.' פּ',
        \   'tables': s:expanded_icon.' 藺',
        \   'table': s:expanded_icon.' ',
        \ },
        \ 'collapsed': {
        \   'db': s:collapsed_icon.' ',
        \   'buffers': s:collapsed_icon.' ',
        \   'saved_queries': s:collapsed_icon.' ',
        \   'schemas': s:collapsed_icon.' ',
        \   'schema': s:collapsed_icon.' פּ',
        \   'tables': s:collapsed_icon.' 藺',
        \   'table': s:collapsed_icon.' ',
        \ },
        \ 'saved_query': '  ',
        \ 'new_query': '  璘',
        \ 'tables': '  離',
        \ 'buffers': '  ﬘',
        \ 'add_connection': '  ',
        \ 'connection_ok': '✓',
        \ 'connection_error': '✕',
        \ }
endif

let g:dbui_icons.expanded = extend(g:dbui_icons.expanded, s:expanded_icons)
let g:dbui_icons.collapsed = extend(g:dbui_icons.collapsed, s:collapsed_icons)
silent! call remove(s:dbui_icons, 'expanded')
silent! call remove(s:dbui_icons, 'collapsed')
let g:dbui_icons = extend(g:dbui_icons, s:dbui_icons)

function! s:set_mapping(key, plug, ...) abort
  if g:dbui_disable_mappings
    return
  endif

  let mode = a:0 > 0 ? a:1 : 'n'
  if !hasmapto(a:plug, mode)
    silent! exe mode.'map <buffer><nowait> '.a:key.' '.a:plug
  endif
endfunction

augroup dbui
  autocmd!
  autocmd FileType sql call s:set_mapping('<Leader>W', '<Plug>(DBUI_SaveQuery)')
  autocmd FileType sql call s:set_mapping('<Leader>E', '<Plug>(DBUI_EditBindParameters)')
  autocmd FileType sql call s:set_mapping('<Leader>S', '<Plug>(DBUI_ExecuteQuery)')
  autocmd FileType sql call s:set_mapping('<Leader>S', '<Plug>(DBUI_ExecuteQuery)', 'v')
  autocmd FileType dbui call s:set_mapping('o', '<Plug>(DBUI_SelectLine)')
  autocmd FileType dbui call s:set_mapping('S', '<Plug>(DBUI_SelectLineVsplit)')
  autocmd FileType dbui call s:set_mapping('R', '<Plug>(DBUI_Redraw)')
  autocmd FileType dbui call s:set_mapping('d', '<Plug>(DBUI_DeleteLine)')
  autocmd FileType dbui call s:set_mapping('A', '<Plug>(DBUI_AddConnection)')
  autocmd FileType dbui call s:set_mapping('H', '<Plug>(DBUI_ToggleDetails)')
  autocmd FileType dbui call s:set_mapping('r', '<Plug>(DBUI_RenameLine)')
  autocmd FileType dbui call s:set_mapping('q', '<Plug>(DBUI_Quit)')
  autocmd BufRead,BufNewFile *.dbout set filetype=dbout
  autocmd FileType dbout setlocal foldmethod=expr foldexpr=db_ui#dbout#foldexpr(v:lnum) | normal!zo
  autocmd FileType dbout
        \ nnoremap <silent><buffer> <Plug>(DBUI_JumpToForeignKey) :call db_ui#dbout#jump_to_foreign_table()<CR>
        \ | nnoremap <silent><buffer> <Plug>(DBUI_YankCellValue) :call db_ui#dbout#yank_cell_value()<CR>
        \ | nnoremap <silent><buffer> <Plug>(DBUI_YankHeader) :call db_ui#dbout#yank_header()<CR>
        \ | call s:set_mapping('<C-]>', '<Plug>(DBUI_JumpToForeignKey)')
        \ | call s:set_mapping('yic', '<Plug>(DBUI_YankCellValue)')
        \ | call s:set_mapping('yh', '<Plug>(DBUI_YankHeader)')
augroup END

command! DBUI call db_ui#open('<mods>')
command! DBUIToggle call db_ui#toggle()
command! DBUIAddConnection call db_ui#connections#add()
command! DBUIFindBuffer call db_ui#find_buffer()
command! DBUIRenameBuffer call db_ui#rename_buffer()
