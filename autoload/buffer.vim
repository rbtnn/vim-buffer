
if has('vimscript-3')
    scriptversion 3
else
    finish
endif

function! buffer#exec() abort
    let xs = filter(getbufinfo(), { _,x -> filereadable(x['name']) && x['listed'] && bufnr('%') != x['bufnr'] })
    if empty(xs)
        let winid = popup_notification('there are no other buffers', {
                \   'title' : 'buffer',
                \   'pos' : 'center',
                \   'padding' : [1,3,1,3],
                \ })
        call s:set_wincolor(winid)
    elseif getbufvar(bufnr('%'), '&buftype') == 'terminal'
        let winid = popup_notification('current buffer is terminal', {
                \   'title' : 'buffer',
                \   'pos' : 'center',
                \   'padding' : [1,3,1,3],
                \ })
        call s:set_wincolor(winid)
    elseif &modified
        let winid = popup_notification('current buffer is modified', {
                \   'title' : 'buffer',
                \   'pos' : 'center',
                \   'padding' : [1,3,1,3],
                \ })
        call s:set_wincolor(winid)
    else
        for x in xs
            let x['fname'] = fnamemodify(x['name'], ':t')
        endfor
        let max = max(map(deepcopy(xs), { _,x -> len(x['fname']) }))
        let winid = popup_menu(map(xs, { _,x -> printf('%3d "%s"%s line %d', x['bufnr'], x['fname'], repeat(' ', max - len(x['fname'])), x['lnum']) }), {
                \   'title' : 'buffer',
                \   'padding' : [1,3,1,3],
                \   'maxwidth' : &columns * 2 / 3,
                \   'maxheight' : &lines * 2 / 3,
                \   'callback' : function('s:buffer_callback'),
                \ })
        call s:set_wincolor(winid)
    endif
endfunction



function! s:set_wincolor(winid) abort
    let val = get(g:, 'buffer_popup_highlight', '')
    if !empty(val)
        call setwinvar(a:winid, '&wincolor', val)
    endif
endfunction

function! s:buffer_callback(id, key) abort
    if -1 != a:key
        let line = get(getbufline(winbufnr(a:id), a:key), 0, '')
        let m = matchlist(line, '^\s*\(\d\+\)\s\+"\([^"]*\)"\s\+line \(\d\+\)$')
        if !empty(m)
            execute printf('buffer %s', m[1])
        endif
    endif
endfunction

