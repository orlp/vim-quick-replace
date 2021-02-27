" A quick find/replace plugin.
" Author:       Orson Peters <orsonpeters@gmail.com>
" Version:      0.1
" License:      zlib license

if exists("g:loaded_quick_replace") || &cp || v:version < 700
    finish
endif
let g:loaded_quick_replace = 1



augroup quick_replace_after_insert
    autocmd!
    autocmd! InsertLeave * :call <SID>QuickReplaceAfterInsert()
augroup END

function s:StartSearch(backward, hist)
    if a:hist
        call histadd("/", @/)
    endif

    " Must set hlsearch/searchforward from feedkeys, or it doesn't apply.
    if a:backward
        call feedkeys(":\<C-U>let v:searchforward=0\<CR>:\<C-U>set hlsearch\<CR>", 'n')
    else
        call feedkeys(":\<C-U>set hlsearch\<CR>", 'n')
    endif
endfunction

function s:StartWordSearch(backward, hist)
    let @/ = '\C\V\<'.expand('<cword>').'\>'
    call s:StartSearch(a:backward, a:hist)
endfunction

function s:StartSelectionSearch(backward, hist)
    let l:old_reg = getreg('"')
    let l:old_regtype = getregtype('"')
    normal! gvy
    let l:query = getreg('"')
    call setreg('"', l:old_reg, l:old_regtype)
    let l:query = escape(l:query, '\')
    let l:query = substitute(l:query, "\n", '\\n', 'g')

    let @/ = '\V' . l:query
    call s:StartSearch(a:backward, a:hist)
endfunction

let s:quick_replace_after_insert = 0
function! s:QuickReplaceAfterInsert()
    if s:quick_replace_after_insert
        let s:quick_replace_after_insert = 0
        call feedkeys('n', 'n')
        call repeat#set("\<Plug>RepeatQuickReplace")
    endif
endfunction

function! s:QuickReplaceSelection(backward)
    let s:quick_replace_after_insert = 1
    call s:StartSelectionSearch(a:backward, 0)
    if a:backward
        call feedkeys("cgN", 'n')
    else
        call feedkeys("cgn", 'n')
    endif
endfunction

function! s:QuickReplaceWord(backward)
    let s:quick_replace_after_insert = 1
    call s:StartWordSearch(a:backward, 0)
    if a:backward
        call feedkeys("cgN", 'n')
    else
        call feedkeys("cgn", 'n')
    endif
endfunction

function! s:RepeatQuickReplace()
    " Move to next occurrence and check if we were already on it using gn.
    let l:old_visual_start = getpos("'<")
    let l:old_visual_end = getpos("'>")
    let [l:line_cur, l:col_cur] = getpos(".")[1:2]
    if v:searchforward
        silent! exe 'normal! gn'
    else
        silent! exe 'normal! gN'
    endif
    if mode() != 'v'
        " No match found, use feedkeys n to get native Vim error.
        call feedkeys('n', 'n')
    else
        " Exit selection, move cursor to start, and register selection size.
        silent! exe "normal! \<Esc>`<"
        let [l:line_start, l:col_start] = getpos("'<")[1:2]
        let [l:line_end, l:col_end] = getpos("'>")[1:2]

        let l:already_on_match = (
            \ (l:line_start < l:line_cur || l:line_start == l:line_cur && l:col_start <= l:col_cur) &&
            \ (l:line_end > l:line_cur || l:line_end == l:line_cur && l:col_end >= l:col_cur))

        if l:already_on_match
            silent! exe "normal! cgn\<C-A>\<Esc>"
            call feedkeys('n', 'n')
        endif
    endif

    call setpos("'<", l:old_visual_start)
    call setpos("'>", l:old_visual_end)
    call repeat#set("\<Plug>RepeatQuickReplace")
endfunction

nnoremap <silent> <Plug>RepeatQuickReplace :<C-U>call <SID>RepeatQuickReplace()<CR>


" The mappings a user cares about.
nnoremap <silent> <Plug>(QuickReplaceWord)              :<C-U>call <SID>QuickReplaceWord(0)<CR>
nnoremap <silent> <Plug>(QuickReplaceWordBackward)      :<C-U>call <SID>QuickReplaceWord(1)<CR>
xnoremap <silent> <Plug>(QuickReplaceSelection)         :<C-U>call <SID>QuickReplaceSelection(0)<CR>
xnoremap <silent> <Plug>(QuickReplaceSelectionBackward) :<C-U>call <SID>QuickReplaceSelection(1)<CR>
nnoremap <silent> <Plug>(StartWordSearch)               :<C-U>call <SID>StartWordSearch(0, 1)<CR>
nnoremap <silent> <Plug>(StartWordSearchBackward)       :<C-U>call <SID>StartWordSearch(1, 1)<CR>
xnoremap <silent> <Plug>(StartSelectionSearch)          :<C-U>call <SID>StartSelectionSearch(0, 1)<CR>
xnoremap <silent> <Plug>(StartSelectionSearchBackward)  :<C-U>call <SID>StartSelectionSearch(1, 1)<CR>
