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

  if exists('g:VimTodoListsCustomKeyMapper')
    try
      call call(g:VimTodoListsCustomKeyMapper, [])
    catch
      echo 'VimTodoLists: Error in custom key mapper.'
           \.' Falling back to default mappings'
      call VimTodoListsSetItemMode()
    endtry
  else
    call VimTodoListsSetItemMode()
  endif

endfunction


" Sets the item done
function! VimTodoListsSetItemDone(lineno)
  let l:line = getline(a:lineno)
  call setline(a:lineno, substitute(l:line, '^\(\s*\)\[ \]', '\1[X]', ''))
endfunction


" Sets the item not done
function! VimTodoListsSetItemNotDone(lineno)
  let l:line = getline(a:lineno)
  call setline(a:lineno, substitute(l:line, '^\(\s*\)\[X\]', '\1[ ]', ''))
endfunction


" Checks that line is a todo list item
function! VimTodoListsLineIsItem(line)
  if match(a:line, '^\s*\[[ X]\].*') != -1
    return 1
  else

  return 0
endfunction


" Checks that item is not done
function! VimTodoListsItemIsNotDone(line)
  if match(a:line, '^\s*\[ \].*') != -1
    return 1
  else
    return 0
  endif

  return 0
endfunction


" Checks that item is done
function! VimTodoListsItemIsDone(line)
  if match(a:line, '^\s*\[X\].*') != -1
    return 1
  else
    return 0
  endif

  return 0
endfunction


" Counts the number of leading spaces
function! VimTodoListsCountLeadingSpaces(line)
  return (strlen(a:line) - strlen(substitute(a:line, '^\s*', '', '')))
endfunction


" Returns the line number of the parent
function! VimTodoListsFindParent(lineno)
  let l:indent = VimTodoListsCountLeadingSpaces(getline(a:lineno))
  let l:parent_lineno = -1

  for current_line in range (a:lineno, 1, -1)
    if (VimTodoListsLineIsItem(getline(current_line)) &&
      \ VimTodoListsCountLeadingSpaces(getline(current_line)) < l:indent)
      let l:parent_lineno = current_line
      break
    endif
  endfor

  return l:parent_lineno
endfunction


" Returns the line number of the last child
function! VimTodoListsFindLastChild(lineno)
  let l:indent = VimTodoListsCountLeadingSpaces(getline(a:lineno))
  let l:last_child_lineno = a:lineno

  " If item is the last line in the buffer it has no children
  if a:lineno == line('$')
    return l:last_child_lineno
  endif

  for current_line in range (a:lineno + 1, line('$'))
    if (VimTodoListsLineIsItem(getline(current_line)) &&
      \ VimTodoListsCountLeadingSpaces(getline(current_line)) > l:indent)
      let l:last_child_lineno = current_line
    else
      break
    endif
  endfor

  return l:last_child_lineno
endfunction


" Marks the parent done if all children are done
function! VimTodoListsUpdateParent(lineno)
  let l:parent_lineno = VimTodoListsFindParent(a:lineno)

  " No parent item
  if l:parent_lineno == -1
    return
  endif

  let l:last_child_lineno = VimTodoListsFindLastChild(l:parent_lineno)

  " There is no children
  if l:last_child_lineno == l:parent_lineno
    return
  endif

  for current_line in range(l:parent_lineno + 1, l:last_child_lineno)
    if VimTodoListsItemIsNotDone(getline(current_line)) == 1
      " Not all children are done
      call VimTodoListsSetItemNotDone(l:parent_lineno)
      call VimTodoListsUpdateParent(l:parent_lineno)
      return
    endif
  endfor

  call VimTodoListsSetItemDone(l:parent_lineno)
  call VimTodoListsUpdateParent(l:parent_lineno)
endfunction


" Applies the function for each child
function! VimTodoListsForEachChild(lineno, function)
  let l:last_child_lineno = VimTodoListsFindLastChild(a:lineno)

  " No children items
  if l:last_child_lineno == a:lineno
    call call(a:function, [a:lineno])
    return
  endif

  for current_line in range(a:lineno, l:last_child_lineno)
    call call(a:function, [current_line])
  endfor

endfunction


" Sets mapping for normal navigation and editing mode
function! VimTodoListsSetNormalMode()
  nunmap <buffer> o
  nunmap <buffer> O
  nunmap <buffer> j
  nunmap <buffer> k
  nnoremap <buffer> <Space> :VimTodoListsToggleItem<CR>
  vnoremap <buffer> <Space> :'<,'>VimTodoListsToggleItem<CR>
  noremap <buffer> <leader>e :silent call VimTodoListsSetItemMode()<CR>
endfunction


" Sets mappings for faster item navigation and editing
function! VimTodoListsSetItemMode()
  nnoremap <buffer> o :VimTodoListsCreateNewItemBelow<CR>
  nnoremap <buffer> O :VimTodoListsCreateNewItemAbove<CR>
  nnoremap <buffer> j :VimTodoListsGoToNextItem<CR>
  nnoremap <buffer> k :VimTodoListsGoToPreviousItem<CR>
  nnoremap <buffer> <Space> :VimTodoListsToggleItem<CR>
  vnoremap <buffer> <Space> :VimTodoListsToggleItem<CR>
  inoremap <buffer> <CR> <CR><ESC>:VimTodoListsCreateNewItem<CR>
  noremap <buffer> <leader>e :silent call VimTodoListsSetNormalMode()<CR>
endfunction


" Creates a new item above the current line
function! VimTodoListsCreateNewItemAbove()
  normal! O  [ ] 
  startinsert!
endfunction


" Creates e new item below the current line
function! VimTodoListsCreateNewItemBelow()
  normal! o  [ ] 
  startinsert!
endfunction


" Creates e new item in the current line
function! VimTodoListsCreateNewItem()
  normal! 0i  [ ] 
  startinsert!
endfunction


" Moves te cursor to the next item
function! VimTodoListsGoToNextItem()
  normal! $
  silent! exec '/^\s*\[.\]'
  silent! exec 'noh'
  normal! l
endfunction


" Moves te cursor to the previous item
function! VimTodoListsGoToPreviousItem()
  normal! 0
  silent! exec '?^\s*\[.\]'
  silent! exec 'noh'
  normal! l
endfunction


" Toggles todo list item
function! VimTodoListsToggleItem()
  let l:line = getline('.')

  if VimTodoListsItemIsNotDone(l:line) == 1
    call VimTodoListsForEachChild(line('.'), 'VimTodoListsSetItemDone')
  elseif VimTodoListsItemIsDone(l:line) == 1
    call VimTodoListsForEachChild(line('.'), 'VimTodoListsSetItemNotDone')
  endif

  " Restore the cursor position
  normal! f[l

  call VimTodoListsUpdateParent(line('.'))
endfunction


"Plugin startup code
if !exists('g:vimtodolists_plugin')
  let g:vimtodolists_plugin = 1

  if exists('vimtodolists_auto_commands')
    echoerr 'VimTodoLists: vimtodolists_auto_commands group already exists'
    exit
  endif

  "Defining auto commands
  augroup vimtodolists_auto_commands
    autocmd!
    autocmd BufRead,BufNewFile *.todo call VimTodoListsInit()
  augroup end

  "Defining plugin commands
  command! VimTodoListsCreateNewItemAbove silent call VimTodoListsCreateNewItemAbove()
  command! VimTodoListsCreateNewItemBelow silent call VimTodoListsCreateNewItemBelow()
  command! VimTodoListsCreateNewItem silent call VimTodoListsCreateNewItem()
  command! VimTodoListsGoToNextItem silent call VimTodoListsGoToNextItem()
  command! VimTodoListsGoToPreviousItem silent call VimTodoListsGoToPreviousItem()
  command! -range VimTodoListsToggleItem silent <line1>,<line2>call VimTodoListsToggleItem()
endif

