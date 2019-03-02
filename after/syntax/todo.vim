"Syntax commands ordering is important due to order of the matching
syntax match vimTodoListsDone '^\s*- \[X\].*'
syntax match vimTodoListsNormal '^\s*- \[ \]\s*.*'
syntax match vimTodoListsImportant '^\s*- \[ \]\s*!.*'

highlight link vimTodoListsDone Comment
highlight link vimTodoListsNormal Normal
highlight link vimTodoListsImportant Underlined
