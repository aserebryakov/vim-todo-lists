vim-todo-lists
==============

**vim-todo-lists** is a Vim plugin for TODO lists management.

Installation
------------

#### Install vim-todo-lists

##### Pathogen

    $ cd ~/.vim/bundle
    $ git clone https://github.com/aserebryakov/vim-todo-lists.git

##### NeoBundle

    NeoBundle 'aserebryakov/vim-todo-lists'

##### Without plugin manager

Clone or download this repository and copy its contents to your `~/.vim/`
directory.

Usage
-----

Plugin is automatically applied for files with `.todo` extension.

##### TODO Items

The sequence matching the expression '^  [ ] ' marks a line as a TODO list item.

###### Example

```
  [ ] Not done
  [X] Done
```

##### Commands

* `:VimTodoListsCreateNewItemAbove` - creates a new item in a line above cursor
* `:VimTodoListsCreateNewItemBelow` - creates a new item in a line below cursor
* `:VimTodoListsCreateNewItem`      - creates a new item in current line
* `:VimTodoListsGoToNextItem`       - go to the next item
* `:VimTodoListsGoToPreviousItem`   - go to the previous item
* `:VimTodoListsToggleItem`         - toggles the item

##### Default key mappings

###### Item editing mode

* `j` - go to next item
* `k` - go to previous item
* `o` - create new item above the cursor
* `O` - create new item below the cursor
* `<Space>` - toggle current item
* `<CR>` - create new item in `insert mode`
* `<leader>e` - switch to normal editing mode

###### Normal editing mode

* `j`, `k`, `o`, `O`, `<CR>` - no special behavior
* `<Space>` - toggle current item
* `<leader>e` - switch to item editing mode

##### Custom key mappings

The `g:VimTodoListsCustomKeyMapper` variable should contain a name of the function
implementing custom mappings.

###### Example

```
let g:VimTodoListsCustomKeyMapper = 'VimTodoListsCustomMappings'

function! VimTodoListsCustomMappings()
  nnoremap <buffer> s :VimTodoListsToggleItem<CR>
  nnoremap <buffer> <Space> :VimTodoListsToggleItem<CR>
  noremap <buffer> <leader>e :silent call VimTodoListsSetItemMode()<CR>
endfunction
```

Future features
---------------

* TODO lists folder selection
* Create new TODO list
* Archive current TODO list in the folder
* Show archived lists
* Open list from archive

Contribution
------------

Source code and issues are hosted on GitHub:

    https://github.com/aserebryakov/vim-todo-lists

License
-------

[MIT License](https://opensource.org/licenses/MIT)

Changelog
---------

#### 0.1.0

* Easy navigation in TODO list
* Easy adding new items
* Easy items toggling

#### 0.1.1

* Fixes broken compatibility with the [filestyle](https://github.com/aserebryakov/filestyle) plugin

#### 0.2.0

* Adds an option to configure custom key mappings

Credits
-------

* Alexander Serebryakov, author ([GitHub](https://github.com/aserebryakov))
