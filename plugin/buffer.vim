
if has('vimscript-3')
    scriptversion 3
else
    finish
endif

let g:loaded_buffer = 1

command! -bar -nargs=0   Buffer      :call buffer#exec()

