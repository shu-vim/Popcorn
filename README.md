# Popcorn

You can define your own pop-up menu.

## Prerequisites

- Vim9
- `+popupwin`

## Usage

```
:Popcorn
```

- j, k: up, down
- h, l: menu level (h: go up, l: go down)
- enter: execute
- q, esc: quit

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
        {name: 'Split(--)', execute: 'split'},
        {name: 'Split(|)', execute: 'vsplit'},
    ]},
    {name: 'Time', nameeval: 'strftime("%Y-%m-%d %H:%M:%S")', execute: 'Popcorn'},
]
```

You can set menu items directly to g:PopcornItems.

You can also use g:Popcorn_clear(), g:Popcorn_add() and g:Popcorn_remove().

### Rule

1. Each item must have `name`
2. Must have one of (`execute`, `executeeval`, `sub`)
3. `nameeval` is eval()-ed when displayed (priority: `nameeval` > `name`)
4. `executeeval` is eval()-ed when executed (priority: `executeeval` > `execute`)
5. `default` item is executed when enter is pressed on its parent

---

Maintainer: Shuhei Kubota <kubota.shuhei+vim@gmail.com>

<!-- vim: set et ft=markdown sts=4 sw=4 ts=4 tw=0 : -->
