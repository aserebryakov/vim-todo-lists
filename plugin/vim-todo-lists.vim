" MIT License
"
" Copyright (c) 2017 Alexander Serebryakov (alex.serebr@gmail.com)
"
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to
" deal in the Software without restriction, including without limitation the
" rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
" sell copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
"
" The above copyright notice and this permission notice shall be included in
" all copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
" FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
" IN THE SOFTWARE.


" Initializes plugin settings and mappings
function! VimTodoListsInit()
  set filetype=todo
  setlocal tabstop=2
  setlocal shiftwidth=2 expandtab
  setlocal cursorline
  setlocal noautoindent
  nnoremap <buffer> o o  [ ] 
  nnoremap <buffer> O O  [ ] 
  nnoremap <buffer> j $/^  \[.\]<CR>:noh<CR> f f 
  nnoremap <buffer> k 0?^  \[.\]<CR>:noh<CR> f f 
  nnoremap <buffer> <Space> :silent call VimTodoListsToggleItem()<CR>
  inoremap <buffer> <CR> <CR>  [ ] 
endfunction


" Toggles todo item in list
function! VimTodoListsToggleItem()
  let l:line = getline('.')

  if match(l:line, '^  \[ \] .*') != -1
    call setline('.', substitute(l:line, '^  \[ \] ', '  [X] ', ''))
  elseif match(l:line, '^  \[X\] .*') != -1
    call setline('.', substitute(l:line, '^  \[X\] ', '  [ ] ', ''))
  endif

endfunction


"Plugin startup code
if !exists('g:vimtodolists_plugin')
  let g:vimtodolists_plugin = 1

  "Defining auto commands
  augroup filestyle_auto_commands
    autocmd!
    autocmd BufRead,BufNewFile *.todo call VimTodoListsInit()
  augroup end

  "Defining plugin commands
endif

