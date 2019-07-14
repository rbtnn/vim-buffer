
if has('vimscript-3')
    scriptversion 3
else
    finish
endif

function! buffer#exec() abort
    let xs = filter(getbufinfo(), { _,x -> filereadable(x['name']) && x['listed'] && bufnr('%') != x['bufnr'] })
    if empty(xs)
        call popup_notification('there are no other buffers', { 'title' : 'buffer', 'pos' : 'center', })
    elseif getbufvar(bufnr('%'), '&buftype') == 'terminal'
        call popup_notification('current buffer is terminal', { 'title' : 'buffer', 'pos' : 'center', })
    elseif &modified
        call popup_notification('current buffer is modified', { 'title' : 'buffer', 'pos' : 'center', })
    else
        let wnr = popup_menu(map(xs, { _,x -> x['name'] }), {
                \   'title' : 'buffer',
                \   'maxwidth' : &columns * 2 / 3,
                \   'maxheight' : &lines * 2 / 3,
                \   'callback' : function('s:buffer_callback'),
                \ })
    endif
endfunction

function! s:buffer_callback(id, key) abort
    if -1 != a:key
        execute printf('buffer %s', escape(getbufline(winbufnr(a:id), a:key)[0], ' '))
    endif
endfunction

