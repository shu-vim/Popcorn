# Popcorn

You can define your own pop-up menu.

## Prerequisites

- Vim9
- `+popupwin`

## Usage

```
:Popcorn
```

### normal mode

- j, k: up, down
- h, l(enter): menu level (h: go up, l: go down)
- enter: execute
- q, esc: quit
- /: search mode
- upper case: search mode when g:PopcornSearchOnUpper

### search mode

- ctrl-n, ctrl-p: up, down
- enter: execute
- esc: normal mode
- backspace, ctrl-h: backspace
- alpha nuberic: search

## Customize

```
# vim9script

g:PopcornItems = [
    {name: 'LSP', sub: [
        {name: 'Hover', execute: 'LspHover', default: true},
        {name: 'Definition', execute: 'LspDefinition'},
        {name: 'Rename', execute: 'LspRename'},
    ]},
    {name: 'Window', sub: [
        {name: 'Alt', executeeval: '"buffer " .. bufnr("#")', default: true},
        {name: '-'},
        {name: 'Split(--)', execute: 'split'},
        {name: 'Split(|)', execute: 'vsplit'},
    ]},
    {name: '-'},
    {name: 'Time', nameeval: 'strftime("%Y-%m-%d %H:%M:%S")', skip: true},
]
```

You can set menu items directly to g:PopcornItems.

You can also use g:Popcorn_clear(), g:Popcorn_add() and g:Popcorn_remove().

### Rule

1. Each item must have `name`
2. Must have one of (`execute`, `executeeval`, `sub`, `skip`)
3. `nameeval` is eval()-ed when displayed (priority: `nameeval` > `name`)
4. `executeeval` is eval()-ed when executed (priority: `executeeval` > `execute`)
5. 'execute' (and 'executeeval') can be a string or a list of strings
6. 'default' item is executed when enter is pressed on its parent
7. A separator is {name: '-'}
8. 'skip' is true if the cursor skips the item

### Highlights

- g:PopcornGroupHighlight = 'Comment'
- g:PopcornSeparatorHighlight = 'Comment'
- g:PopcornSearchOnUpper = false

---

Maintainer: Shuhei Kubota <kubota.shuhei+vim@gmail.com>

<!-- vim: set et ft=markdown sts=4 sw=4 ts=4 tw=0 : -->
