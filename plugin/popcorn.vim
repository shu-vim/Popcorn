vim9script

command! Popcorn g:Popcorn_popup()

if !exists('g:PopcornItems')
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
endif

def! g:Popcorn_clear()
    g:PopcornItems = []
enddef

def! g:Popcorn_add(item: dict<any>)
    if !has_key(item, 'name')
        echoe 'name required'
        return
    endif

    if !has_key(item, 'execute') && !has_key(item, 'executeeval') && !has_key(item, 'sub')
        echoe 'execute, executeeval or sub is required'
        return
    endif

    add(g:PopcornItems, item)
enddef

def! g:Popcorn_remove(name: string)
    var idx = -1
    for i in range(len(g:PopcornItems))
        if g:PopcornItems[i].name == name
            idx = i
            break
        endif
    endfor

    if idx != -1
        remove(g:PopcornItems, idx)
    endif
enddef

def! g:Popcorn_popup()
    if type(g:PopcornItems) != 3 || len(g:PopcornItems) == 0
        return
    endif

    var items = BuildItemLines(Root(g:PopcornItems))

    var winid = popup_create(items, {
        pos: 'center',
        zindex: 200,
        drag: 1,
        wrap: 0,
        border: [],
        cursorline: 1,
        padding: [0, 1, 0, 1],
        filter: Filter, # 'popup_filter_menu',
        mapping: 0,
        callback: Callback,
    })
    setwinvar(winid, 'Popcorn_parentIndices', [])
enddef

def Root(items: list<dict<any>>): dict<any>
    return {name: '', sub: g:PopcornItems}
enddef

def Filter(winid: number, key: string): bool
    # get current line number
    call win_execute(winid, 'w:lnum = line(".")')
    var lnum = getwinvar(winid, 'lnum', 1)

    var indices = getwinvar(winid, 'Popcorn_parentIndices', [])
    var bufnr = winbufnr(winid)

    var root = Root(g:PopcornItems)
    var parent = DeriveParent(root, indices)

    if key == 'q'
        popup_close(winid, -1)
        return true
    endif

    if len(indices) >= 1 && (key == 'h' || key == "\<s-tab>")
        # pop an index
        if len(indices) >= 1
            remove(indices, len(indices) - 1)
        endif
        setwinvar(winid, 'Popcorn_parentIndices', indices)
        parent = DeriveParent(root, indices)

        # render parent items
        Redraw(winid, bufnr, parent, lnum)
        return true
    endif

    if has_key(parent.sub[lnum - 1], 'sub')
        if (key == 'l' || key == "\<tab>")
            # push an index
            indices = add(indices, lnum - 1)
            setwinvar(winid, 'Popcorn_parentIndices', indices)
            parent = DeriveParent(root, indices)

            # render child items
            Redraw(winid, bufnr, parent, lnum)
            return true
        endif

        # search a default sub item and execute it
        if key == "\<cr>"
            # push an index
            indices = add(indices, lnum - 1)
            setwinvar(winid, 'Popcorn_parentIndices', indices)
            parent = DeriveParent(root, indices)

            var defidx: number = IndexOfDefault(parent)
            if defidx != -1
                popup_close(winid, defidx + 1)
            else
                # render child items
                Redraw(winid, bufnr, parent, lnum)
            endif
            return true
        endif
    endif

    return popup_filter_menu(winid, key)
enddef

def Callback(winid: number, result: any)
    if result == -1
        return
    endif

    var indices = getwinvar(winid, 'Popcorn_parentIndices', [])
    var parent = DeriveParent(Root(g:PopcornItems), indices)

    var item = parent.sub[result - 1]
    if has_key(item, 'executeeval')
        if type(item.executeeval) == 3 # list
            for cmd in item.executeeval
                try
                    execute eval(cmd)
                catch
                    echoe 'executeeval(' .. cmd .. '): ' .. v:exception
                    return
                endtry
            endfor
        else
            execute eval(item.executeeval)
        endif
    else
        if type(item.execute) == 3 # list
            for cmd in item.execute
                try
                    execute cmd
                catch
                    echoe 'execute(' .. cmd .. '): ' .. v:exception
                    return
                endtry
            endfor
        else
            execute item.execute
        endif
    endif
enddef

def Redraw(winid: number, bufnr: number, parent: dict<any>, lnum: number)
    var lines = BuildItemLines(parent)
    deletebufline(bufnr, 1, 100)
    setbufline(bufnr, 1, lines)
    for i in range(lnum - 1)
        win_execute(winid, 'normal k')
    endfor

    popup_setoptions(winid, {title: parent.name})
enddef

def BuildItemLines(parent: dict<any>): list<string>
    var maxwid: number = 0
    for item in parent.sub
        if has_key(item, 'nameeval')
            item.name_ = eval(item.nameeval)
        else
            item.name_ = item.name
        endif

        var defidx: number = IndexOfDefault(item)
        if defidx != -1
            item.name_ = item.name_ .. ' (' .. item.sub[defidx].name .. ')'
        endif

        var w = strdisplaywidth(item.name_)
        if w > maxwid
            maxwid = w
        endif
    endfor

    var lines: list<string> = []
    for item in parent.sub
        lines = add(lines, item.name_ .. (has_key(item, 'sub') ? repeat(' ', maxwid - strdisplaywidth(item.name_)) .. ' >>' : ''))
    endfor

    return lines
enddef

def IndexOfDefault(item: dict<any>): number
    if !has_key(item, 'sub')
        return -1
    endif

    for i in range(len(item.sub))
        if get(item.sub[i], 'default', false)
            return i
        endif
    endfor

    return -1
enddef

def DeriveParent(root: dict<any>, indices: list<number>): dict<any>
    var parent = root
    for i in indices
        parent = parent.sub[i]
    endfor
    return parent
enddef

# vim: set et ft=vim sts=4 sw=4 ts=4 tw=78 : 
