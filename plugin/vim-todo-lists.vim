" MIT License
"
" Copyright (c) 2020 Alexander Serebryakov (alex.serebr@gmail.com)
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
" Hack to fix infinit loop on set filetype command
function VimTodoListsInit()
    " Just set this and let the autocommand do the rest of the work.
    set filetype=todo
endfunction

function! VimTodoListsPostInit()

  " Keep the same indent as on the current line or always makes a root item
  if !exists('g:VimTodoListsKeepSameIndent')
    let g:VimTodoListsKeepSameIndent = 1
  endif

  if !exists('g:VimTodoListsDatesEnabled')
    let g:VimTodoListsDatesEnabled = 0
  endif

  if !exists('g:VimTodoListsDateCompleteEnabled')
    let g:VimTodoListsDateCompleteEnabled = 0
  endif

  if !exists('g:VimTodoListsDatesFormat')
    let g:VimTodoListsDatesFormat = "%X, %d %b %Y"
  endif

  setlocal tabstop=2
  setlocal shiftwidth=2 expandtab
  setlocal cursorline
  setlocal noautoindent
  setlocal nosi

  call VimTodoListsInitializeTokens()
  call VimTodoListsInitializeSyntax()

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

" Initializes done/undone tokens
function! VimTodoListsInitializeTokens()
  let g:VimTodoListsEscaped = '*[]'

  if !exists('g:VimTodoListsUndoneItem')
    let g:VimTodoListsUndoneItem = '- [ ]'
  endif

  if !exists('g:VimTodoListsDoneItem')
    let g:VimTodoListsDoneItem = '- [X]'
  endif

  let g:VimTodoListsDoneItemEscaped = escape(g:VimTodoListsDoneItem, g:VimTodoListsEscaped)
  let g:VimTodoListsUndoneItemEscaped = escape(g:VimTodoListsUndoneItem, g:VimTodoListsEscaped)
endfunction

" Initiaizes syntax
function! VimTodoListsInitializeSyntax()
  execute("syntax match vimTodoListsDone '^\\s*".g:VimTodoListsDoneItemEscaped.".*'")
  execute("syntax match vimTodoListsNormal '^\\s*".g:VimTodoListsUndoneItemEscaped.".*'")
  execute("syntax match vimTodoListsImportant '^\\s*".g:VimTodoListsUndoneItemEscaped."\\s*!.*'")

  highlight link vimTodoListsDone Comment
  highlight link vimTodoListsNormal Normal
  highlight link vimTodoListsImportant Underlined
endfunction

" Sets the item done
function! VimTodoListsSetItemDone(lineno)
  let l:line = getline(a:lineno)
  call setline(a:lineno, substitute(l:line, '^\(\s*\)'.g:VimTodoListsUndoneItemEscaped, '\1'.g:VimTodoListsDoneItem, ''))
  if(g:VimTodoListsDateCompleteEnabled == 1)
    let l:line = getline(a:lineno)
    let l:date = strftime(g:VimTodoListsDatesFormat)
    call setline(a:lineno, substitute(l:line, '$', ' (Done - '.l:date.')', ''))
  endif
endfunction


" Sets the item not done
function! VimTodoListsSetItemNotDone(lineno)
  let l:line = getline(a:lineno)
  call setline(a:lineno, substitute(l:line, '^\(\s*\)'.g:VimTodoListsDoneItemEscaped, '\1'.g:VimTodoListsUndoneItem, ''))
  "if date complete flag is enabled the assume that we have a date at the end and see if we can substitute it.
  if(g:VimTodoListsDateCompleteEnabled == 1)
    "Get a very specific filter expression to substitute in the hopes that we don't delete something we shouldn't.
    "A bit of a hack.  First, we have strftime return a formatted time based on current dates format.  Must match as if we were appending.
    let l:date = strftime(g:VimTodoListsDatesFormat)
    "Then, we replace all alpha-numeric values in that date and time with '.' characters, regex matches this to any character.
    let l:datefilter = substitute(l:date, '[0-9A-z]', '.', 'g')
    "Get the line again.
    let l:line = getline(a:lineno)
    "Search for our filtered expression at the end of the line, and delete it.
    "note, there is a very slim chance of deleting something we shouldn't because it looked like something that would match the current time format....
    "I leave this problem to smarter people than I to figure out.
    call setline(a:lineno, substitute(l:line, ' (Done - '.l:datefilter.')$', '', ''))
  endif
endfunction


" Checks that line is a todo list item
function! VimTodoListsLineIsItem(line)
  if match(a:line, '^\s*\('.g:VimTodoListsDoneItemEscaped.'\|'.g:VimTodoListsUndoneItemEscaped.'\).*') != -1
    return 1
  endif

  return 0
endfunction


" Checks that item is not done
function! VimTodoListsItemIsNotDone(line)
  if match(a:line, '^\s*'.g:VimTodoListsUndoneItemEscaped.'.*') != -1
    return 1
  endif

  return 0
endfunction


" Checks that item is done
function! VimTodoListsItemIsDone(line)
  if match(a:line, '^\s*'.g:VimTodoListsDoneItemEscaped.'.*') != -1
    return 1
  endif

  return 0
endfunction


" Returns the line number of the brother item in specified range
function! VimTodoListsBrotherItemInRange(line, range)
  let l:indent = VimTodoListsCountLeadingSpaces(getline(a:line))
  let l:result = -1

  for current_line in a:range
    if VimTodoListsLineIsItem(getline(current_line)) == 0
      break
    endif

    if (VimTodoListsCountLeadingSpaces(getline(current_line)) == l:indent)
      let l:result = current_line
      break
    elseif (VimTodoListsCountLeadingSpaces(getline(current_line)) > l:indent)
      continue
    else
      break
    endif
  endfor

  return l:result
endfunction


" Finds the insert position above the item
function! VimTodoListsFindTargetPositionUp(lineno)
  let l:range = range(a:lineno, 1, -1)
  let l:candidate_line = VimTodoListsBrotherItemInRange(a:lineno, l:range)
  let l:target_line = -1

  while l:candidate_line != -1
    let l:target_line = l:candidate_line
    let l:candidate_line = VimTodoListsBrotherItemInRange(
      \ l:candidate_line, range(l:candidate_line - 1, 1, -1))

    if l:candidate_line != -1 &&
      \ VimTodoListsItemIsNotDone(getline(l:candidate_line)) == 1
      let l:target_line = l:candidate_line
      break
    endif
  endwhile

  return VimTodoListsFindLastChild(l:target_line)
endfunction


" Finds the insert position below the item
function! VimTodoListsFindTargetPositionDown(line)
  let l:range = range(a:line, line('$'))
  let l:candidate_line = VimTodoListsBrotherItemInRange(a:line, l:range)
  let l:target_line = -1

  while l:candidate_line != -1
    let l:target_line = l:candidate_line
    let l:candidate_line = VimTodoListsBrotherItemInRange(
      \ l:candidate_line, range(l:candidate_line + 1, line('$')))
  endwhile

  return VimTodoListsFindLastChild(l:target_line)
endfunction


" Moves the item subtree to the specified position
function! VimTodoListsMoveSubtree(lineno, position)
  if exists('g:VimTodoListsMoveItems')
    if g:VimTodoListsMoveItems != 1
      return
    endif
  endif

  let l:subtree_length = VimTodoListsFindLastChild(a:lineno) - a:lineno + 1

  let l:cursor_pos = getcurpos()
  call cursor(a:lineno, l:cursor_pos[4])

  " Update cursor position
  let l:cursor_pos[1] = a:lineno

  " Copy subtree to the required position
  execute 'normal! ' . l:subtree_length . 'Y'
  call cursor(a:position, l:cursor_pos[4])

  if a:lineno < a:position
    execute 'normal! p'
    " In case of moving item down cursor should be returned to exact position
    " where it was before
    call cursor(l:cursor_pos[1], l:cursor_pos[4])
  else
    let l:indent = VimTodoListsCountLeadingSpaces(getline(a:lineno))

    if VimTodoListsItemIsDone(getline(a:position)) &&
       \ (VimTodoListsCountLeadingSpaces(getline(a:position)) == l:indent)
      execute 'normal! P'
    else
      execute 'normal! p'
    endif

    " In case of moving item up the text became one longer by a subtree length
    call cursor(l:cursor_pos[1] + l:subtree_length, l:cursor_pos[4])
  endif

  " Delete subtree in the initial position
  execute 'normal! ' . l:subtree_length . 'dd'

endfunction


" Moves the subtree up
function! VimTodoListsMoveSubtreeUp(lineno)
  let l:move_position = VimTodoListsFindTargetPositionUp(a:lineno)

  if l:move_position != -1
    call VimTodoListsMoveSubtree(a:lineno, l:move_position)
  endif
endfunction


" Moves the subtree down
function! VimTodoListsMoveSubtreeDown(lineno)
  let l:move_position = VimTodoListsFindTargetPositionDown(a:lineno)

  if l:move_position != -1
    call VimTodoListsMoveSubtree(a:lineno, l:move_position)
  endif
endfunction


" Counts the number of leading spaces
function! VimTodoListsCountLeadingSpaces(line)
  return (strlen(a:line) - strlen(substitute(a:line, '^\s*', '', '')))
endfunction


" Returns the line number of the parent
function! VimTodoListsFindParent(lineno)
  let l:indent = VimTodoListsCountLeadingSpaces(getline(a:lineno))
  let l:parent_lineno = -1

  for current_line in range(a:lineno, 1, -1)
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
      call VimTodoListsMoveSubtreeUp(l:parent_lineno)
      call VimTodoListsUpdateParent(l:parent_lineno)
      return
    endif
  endfor

  call VimTodoListsSetItemDone(l:parent_lineno)
  call VimTodoListsMoveSubtreeDown(l:parent_lineno)
  call VimTodoListsUpdateParent(l:parent_lineno)
endfunction


" Applies the function for each child
function! VimTodoListsForEachChild(lineno, function)
  let l:last_child_lineno = VimTodoListsFindLastChild(a:lineno)

  " Apply the function on children prior to the item.
  " This order is required for proper work of the items moving on toggle
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
  iunmap <buffer> <CR>
  iunmap <buffer> <kEnter>
  nnoremap <buffer><silent> <Space> :VimTodoListsToggleItem<CR>
  vnoremap <buffer><silent> <Space> :'<,'>VimTodoListsToggleItem<CR>
  noremap <buffer><silent> <leader>e :silent call VimTodoListsSetItemMode()<CR>
endfunction


" Sets mappings for faster item navigation and editing
function! VimTodoListsSetItemMode()
  nnoremap <buffer><silent> o :VimTodoListsCreateNewItemBelow<CR>
  nnoremap <buffer><silent> O :VimTodoListsCreateNewItemAbove<CR>
  nnoremap <buffer><silent> j :VimTodoListsGoToNextItem<CR>
  nnoremap <buffer><silent> k :VimTodoListsGoToPreviousItem<CR>
  nnoremap <buffer><silent> <Space> :VimTodoListsToggleItem<CR>
  vnoremap <buffer><silent> <Space> :VimTodoListsToggleItem<CR>
  inoremap <buffer><silent> <CR> <ESC>:call VimTodoListsAppendDate()<CR>:silent call VimTodoListsCreateNewItemBelow()<CR>
  inoremap <buffer><silent> <kEnter> <ESC>:call VimTodoListsAppendDate()<CR>A<CR><ESC>:VimTodoListsCreateNewItem<CR>
  noremap <buffer><silent> <leader>e :silent call VimTodoListsSetNormalMode()<CR>
  nnoremap <buffer><silent> <Tab> :VimTodoListsIncreaseIndent<CR>
  nnoremap <buffer><silent> <S-Tab> :VimTodoListsDecreaseIndent<CR>
  vnoremap <buffer><silent> <Tab> :VimTodoListsIncreaseIndent<CR>
  vnoremap <buffer><silent> <S-Tab> :VimTodoListsDecreaseIndent<CR>
  inoremap <buffer><silent> <Tab> <ESC>:VimTodoListsIncreaseIndent<CR>A
  inoremap <buffer><silent> <S-Tab> <ESC>:VimTodoListsDecreaseIndent<CR>A
endfunction

" Appends date at the end of the line
function! VimTodoListsAppendDate()
  if(g:VimTodoListsDatesEnabled == 1)
    let l:date = strftime(g:VimTodoListsDatesFormat)
    execute "s/$/ (" . l:date . ")"
  endif
endfunction


" Creates a new item above the current line with the same indent
function! VimTodoListsCreateNewItemAbove()
  execute "normal! O" . VimTodoListsIdent() . g:VimTodoListsUndoneItem . " "
  startinsert!
endfunction

" Creates a new item below the current line with the same indent
function! VimTodoListsCreateNewItemBelow()
  execute "normal! o" . VimTodoListsIdent() . g:VimTodoListsUndoneItem . " "
  startinsert!
endfunction

function! VimTodoListsIdent()
  if (g:VimTodoListsKeepSameIndent == 1)
    let l:indentline = join(map(range(1,indent(line('.'))), '" "'), '')
  else
    let l:indentline = ""
  endif

  return l:indentline
endfunction

" Creates a new item in the current line
function! VimTodoListsCreateNewItem()
  execute "normal! 0i" . g:VimTodoListsUndoneItem . " "
  startinsert!
endfunction


" Moves the cursor to the next item
function! VimTodoListsGoToNextItem()
  normal! $
  silent! exec '/^\s*\(' . g:VimTodoListsUndoneItemEscaped . '\|' . g:VimTodoListsDoneItemEscaped . '\)'
  silent! exec 'noh'
  normal! 6l
endfunction


" Moves the cursor to the previous item
function! VimTodoListsGoToPreviousItem()
  normal! 0
  silent! exec '?^\s*\(' . g:VimTodoListsUndoneItemEscaped . '\|' . g:VimTodoListsDoneItemEscaped . '\)'
  silent! exec 'noh'
  normal! 6l
endfunction


" Toggles todo list item
function! VimTodoListsToggleItem()
  let l:line = getline('.')
  let l:lineno = line('.')

  " Store current cursor position
  let l:cursor_pos = getcurpos()

  if VimTodoListsItemIsNotDone(l:line) == 1
    call VimTodoListsForEachChild(l:lineno, 'VimTodoListsSetItemDone')
    call VimTodoListsMoveSubtreeDown(l:lineno)
  elseif VimTodoListsItemIsDone(l:line) == 1
    call VimTodoListsForEachChild(l:lineno, 'VimTodoListsSetItemNotDone')
    call VimTodoListsMoveSubtreeUp(l:lineno)
  endif

  call VimTodoListsUpdateParent(l:lineno)

  " Restore the current position
  " Using the {curswant} value to set the proper column
  call cursor(l:cursor_pos[1], l:cursor_pos[4])
endfunction

" Increases the indent level
function! VimTodoListsIncreaseIndent()
  normal! >>6l
endfunction

" Decreases the indent level
function! VimTodoListsDecreaseIndent()
  normal! <<6l
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
    autocmd BufRead,BufNewFile *.todo.md call VimTodoListsInit()
    " Modified to call post init, as the filetype is already todo.
    " This avoids an infinite loop.
    autocmd FileType todo call VimTodoListsPostInit()
  augroup end

  "Defining plugin commands
  command! VimTodoListsCreateNewItemAbove silent call VimTodoListsCreateNewItemAbove()
  command! VimTodoListsCreateNewItemBelow silent call VimTodoListsCreateNewItemBelow()
  command! VimTodoListsCreateNewItem silent call VimTodoListsCreateNewItem()
  command! VimTodoListsGoToNextItem silent call VimTodoListsGoToNextItem()
  command! VimTodoListsGoToPreviousItem silent call VimTodoListsGoToPreviousItem()
  command! -range VimTodoListsToggleItem silent <line1>,<line2>call VimTodoListsToggleItem()
  command! -range VimTodoListsIncreaseIndent silent <line1>,<line2>call VimTodoListsIncreaseIndent()
  command! -range VimTodoListsDecreaseIndent silent <line1>,<line2>call VimTodoListsDecreaseIndent()
endif
