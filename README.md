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

Plugin is automatically applied for files with `.todo.md` extension.

##### TODO Items

The following example represents TODO items definition by default.

###### Example

```
- [ ] Not done
- [X] Done
```

###### Custom Configuration

You can customize the representation of the item by defining the following variables
to your `.vimrc`

```
let g:VimTodoListsUndoneItem = '- [X]'
let g:VimTodoListsDoneItem = '- [V]'
```

###### Important Item

Important item is defined as `undone item string !`.

```
- [ ] ! Important item
```

##### Items Hierarchy

If one item has lesser indentation than the next one then the first one is meant
to be **parent** and the second to be **child**.

###### Example

```
- [ ] Parent
  - [ ] Child1
  - [ ] Child2
```

###### Rules:

* Changing state of the parent item changes the state of all children items accordantly
* If all children items are marked done, parent will also be marked as done
* If parent is marked as done and one of the children changes state to not done
  parent will also be marked as not done

##### Items Highlighting

Items are highlighted in accordance to the following scheme:

```
- [ ] ! Important item (Underlined)
- [ ] Normal item (Normal)
- [X] Done item (Comment)
```

##### Items moving on state change

By default item when its status is changed is moved in the list in accordance
to the following rules

###### Mark item done

Item marked as done is moved to the end of all done items list.
If done list doesn't exist, item is placed just after the last not done item.

*Before*

```
- [ ] Not Done 1
- [ ] Will be done now
- [ ] Not Done 2
- [X] Done
```

*After*

```
- [ ] Not Done 1
- [ ] Not Done 2
- [X] Done
- [X] Will be done now
```

###### Mark item undone

Undone item is moved to the end of all not done items list.
If all items are marked done, the items is moved before the first done item.

*Before*

```
- [ ] Not Done 1
- [ ] Not Done 2
- [X] Done
- [X] Will be undone now
```
*After*

```
- [ ] Not Done 1
- [ ] Not Done 2
- [ ] Will be done now
- [X] Done
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
* `:VimTodoListsIncreaseIndent`     - increases the indent of current line
* `:VimTodoListsDecreaseIndent`     - decreases the indent of current line

##### Default key mappings

###### Item editing mode

* `j` - go to next item
* `k` - go to previous item
* `O` - create new item above the cursor
* `o` - create new item below the cursor
* `<Space>` - toggle current item
* `<CR>` - create new item in `insert mode`
* `<Tab>` - increases the indent of current (or selected) line(s)
* `<Shift-Tab>` - decreases the indent of current (or selected) line(s)
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

##### Automatic date insertion

Automatic date insertion may be enabled by setting the following in `.vimrc`:

```
let g:VimTodoListsDatesEnabled = 1
```

Date format may be changed by setting the format variable to a valid
`strftime()` string:

```
let g:VimTodoListsDatesFormat = "%a %b, %Y"
```

Contribution
------------

Source code and issues are hosted on GitHub:

    https://github.com/aserebryakov/vim-todo-lists

If you are going to make a pull request, you should use `dev` branch for
functionality implementation to simplify the merge procedure.

License
-------

[MIT License](https://opensource.org/licenses/MIT)

Changelog
---------

#### 0.8.0

**Breaking Change**

* Added option to configure TODO items
* File extension changed to `.todo.md` from `.todo`
* Item indentation level is kept when creating a new one
* Removed migration from older formats
* Added plugin initialization for `todo` filetype
* New item can be created with keypad Enter key
* Makes normal mode keys more consistent

#### 0.7.1

* Syntax highlight is fixed

#### 0.7.0

* Added automatic date insertion feature
* Added mappings for fast increasing/decreasing indent
* Items list are made markdown compatible (old files are updated automatically on load)

#### 0.6.0

* Added items moving on state change

#### 0.5.1

* Fixed the annoying noise when navigating over items in default mode
* Fixed the cursor position after the item is toggled

#### 0.5.0

* Added items highlighting

#### 0.4.0

* Added items hierarchy support

#### 0.3.0

* Added items toggling in visual mode
* Improves work with indentations of list items
* Fixed the error when trying to navigate the buffer that doesn't contain items

#### 0.2.0

* Added an option to configure custom key mappings

#### 0.1.1

* Fixes broken compatibility with the [filestyle](https://github.com/aserebryakov/filestyle) plugin

#### 0.1.0

* Navigation in TODO list
* Adding new items
* Items toggling

Contributors
------------

* Alexander Serebryakov, author ([GitHub](https://github.com/aserebryakov))
* Jake Mason, contributor ([GitHub](https://github.com/jakemason))
* Alexandr Kondratev, contributor ([GitHub](https://github.com/theg4sh))
* Jannis Jorre, contributor ([GitHub](https://github.com/jeyj0))
* thehunmonkgroup, contributor ([GitHub](https://github.com/thehunmonkgroup))
* Suchandra Thapa, contributor ([GitHub](https://github.com/sthapa))
