# vim-quick-replace

This Vim plugin offers the following commands you can map:

    <Plug>(QuickReplaceWord)

Start a quick replace using the word underneath the cursor.
Type your replacement and then use `.` and `n` to repeat the
replacement on other matches.

    <Plug>(QuickReplaceSelection)

Start a quick replace using the current visual mode selection.
Type your replacement and then use `.` and `n` to repeat the
replacement on other matches.

    <Plug>(StartWordSearch)

Starts a search (but doesn't immediately move to the next match)
for the word underneath the cursor.

    <Plug>(StartSelectionSearch)

Starts a search (but doesn't immediately move to the next match)
for the current visual selection.

    <Plug>(QuickReplaceWordBackward)
    <Plug>(QuickReplaceSelectionBackward)
    <Plug>(StartWordSearchBackward)
    <Plug>(StartSelectionSearchBackward)

These all do the same as their above counterparts but search
backwards (like `#` and `?` do compared to `*` and `/`).


My personal mappings to use this plugins are:

    nmap <silent> <Leader>r <Plug>(QuickReplaceWord)
    nmap <silent> <Leader>R <Plug>(QuickReplaceWordBackward)
    xmap <silent> <Leader>r <Plug>(QuickReplaceSelection)
    xmap <silent> <Leader>R <Plug>(QuickReplaceSelectionBackward)
    xmap <silent> * <Plug>(StartSelectionSearch):<C-U>call feedkeys('n')<CR>
    xmap <silent> # <Plug>(StartSelectionSearchBackward):<C-U>call feedkeys('n')<CR>
