vim-todo-lists
==============

**vim-todo-lists** is a Vim plugin for TODO lists management.

Installation
------------

#### Install vim-todo-lists

##### Pathogen

    $ cd ~/.vim/bundle $ git clone https://github.com/aserebryakov/vim-todo-lists.git

##### NeoBundle

    NeoBundle 'aserebryakov/vim-todo-lists'

##### Without plugin manager

Clone or download this repository and copy its contents to your `~/.vim/`
directory.

Usage
-----

Plugin is automatically applied for files with `.todo` extension.

##### TODO Items

The sequence matching the expression '^\s\*[ ].\*' marks a line as a TODO list item.

###### Example

```
  [ ] Not done
  [X] Done
```

##### Items Hierarchy

If one item has lesser indentation than the next one then the first one is meant
to be **parent** and the second to be **child**.

###### Example

```
  [ ] Parent
    [ ] Child1
    [ ] Child2
```

###### Rules:

* Changing state of the parent item changes the state of all children items accordantly
* If all children items are marked done, parent will also be marked as done
* If parent is marked as done and one of the children changes state to not done
  parent will also be marked as not done

##### Items Highlighting

Items are highlighted in accordance to the following scheme:

```
  [ ] ! Important item (Underlined)
  [ ] Normal item (Normal)
  [X] Done item (Comment)
```

##### Items moving on state change

By default item when its status is changed is moved in the list in accordance
to the following rules

###### Mark item done

Item marked as done is moved to the end of all done items list.
If done list doesn't exist, item is placed just after the last not done item.

*Before*

```
[ ] Not Done 1
[ ] Will be done now
[ ] Not Done 2
[X] Done
```

*After*

```
[ ] Not Done 1
[ ] Not Done 2
[X] Done
[X] Will be done now
```

###### Mark item undone

Undone item is moved to the end of all not done items list.
If all items are marked done, the items is moved before the first done item.

*Before*

```
[ ] Not Done 1
[ ] Not Done 2
[X] Done
[X] Will be undone now
```
*After*

```
[ ] Not Done 1
[ ] Not Done 2
[ ] Will be done now
[X] Done
```

###### Interaction with items hierarchy

This feature also affect the items in hierarchy in accordance to the rules above.

###### Disable the items moving

If you don't want items to be moved after state change, you may add the following
line into your `.vimrc` file:

```
let g:VimTodoListsMoveItems = 0
```

##### Commands

* `:VimTodoListsCreateNewItemAbove` - creates a new item in a line above cursor
* `:VimTodoListsCreateNewItemBelow` - creates a new item in a line below cursor
* `:VimTodoListsCreateNewItem`      - creates a new item in current line
* `:VimTodoListsGoToNextItem`       - go to the next item
* `:VimTodoListsGoToPreviousItem`   - go to the previous item
* `:VimTodoListsToggleItem`         - toggles the current item (or selected items in visual mode)

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

* Added an option to configure custom key mappings

#### 0.3.0

* Added items toggling in visual mode
* Improves work with indentations of list items
* Fixed the error when trying to navigate the buffer that doesn't contain items

#### 0.4.0

* Added items hierarchy support

#### 0.5.0

* Added items highlighting

#### 0.5.1

* Fixed the annoying noise when navigating over items in default mode
* Fixed the cursor position after the item is toggled

#### 0.6.0

* Added items moving on state change

Credits
-------

* Alexander Serebryakov, author ([GitHub](https://github.com/aserebryakov))
