" Hack to get it working

hi TabLine     ctermfg=none ctermbg=none gui=none cterm=none term=none
hi TabLineSel  ctermfg=none ctermbg=none gui=none cterm=none term=none
hi TabLineFill ctermfg=none ctermbg=none gui=none cterm=none term=none

autocmd ColorScheme * hi MTActive    gui=underline,bold cterm=underline,bold term=underline,bold ctermfg=none ctermbg=none
autocmd ColorScheme * hi MTReset     gui=none           cterm=none           term=none           ctermfg=none ctermbg=none
