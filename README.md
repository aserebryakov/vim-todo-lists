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

##### Key bindings

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

Credits
-------

* Alexander Serebryakov, author ([GitHub](https://github.com/aserebryakov))
