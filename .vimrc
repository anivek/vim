colorscheme desert
set tabstop=4
set sw=4
set number
syntax on
set autoindent
set cindent

" allow backspacing over indent, line breaks, stop at the start of an insert
set backspace=indent,eol,start 
set wrap
set wrapmargin=4
"set textwidth=79

" Spaces and tabs
set bs=2
set tabstop=4
set softtabstop=4
set shiftwidth=4

" Convert tabs to spaces
" set expandtab

set ignorecase
set smartcase

set cursorline
" Always show status line
set laststatus=2

" Always show tabline
set showtabline=2

set showmatch

" Show a vertical line for 80 chars
highlight ColorColumn ctermbg=lightgrey guibg=lightgrey
set colorcolumn=80

" Enable mouse use
"set mouse=a

set hlsearch

" pathogen  - Manage your 'runtimepath' with ease
" (http://www.vim.org/scripts/script.php?script_id=2332)
execute pathogen#infect()

"
" Powerline
" (https://github.com/Lokaltog/powerline)
" (http://askubuntu.com/questions/283908/how-can-i-install-and-use-powerline-plugin)
"
set rtp+=$HOME/.local/lib/python2.7/site-packages/powerline/bindings/vim/
" Always show statusline
set laststatus=2
" Use 256 colours (Use this setting only if your terminal supports 256 colours)
set t_Co=256

"
" Tagbar
"
autocmd VimEnter * nested :call tagbar#autoopen(1)

" Select all
map <C-A> ggVG

" Vim tab setting
highlight TabLineSel ctermfg=Yellow ctermbg=DarkBlue
highlight TabLine ctermfg=LightGrey ctermbg=DarkBlue
highlight TabLineFill ctermfg=DarkBlue ctermbg=DarkBlue

" highlight CursorLine guibg=lightblue ctermbg=lightgray

let g:tagbar_left=1
nnoremap <silent> <F4> :TagbarToggle<CR>
nnoremap <silent> <F5> :TlistToggle<CR>
nnoremap <silent> <F6> :NERDTreeToggle<CR>

noremap <F7> :tabprevious<CR>
noremap <F8> :tabnext<CR>
noremap <F9> :tabnew<CR>
noremap <F12> :tabclose<CR>

set nobackup
set nowritebackup
set noswapfile

" http://vim.wikia.com/wiki/Improved_hex_editing
nnoremap <C-H> :Hexmode<CR>
inoremap <C-H> <Esc>:Hexmode<CR>
vnoremap <C-H> :<C-U>Hexmode<CR>

" ex command for toggling hex mode - define mapping if desired
command! -bar Hexmode call ToggleHex()

" helper function to toggle hex mode
function! ToggleHex()
	" hex mode should be considered a read-only operation
	" save values for modified and read-only for restoration later,
	" and clear the read-only flag for now
	let l:modified=&mod
	let l:oldreadonly=&readonly
	let &readonly=0
	let l:oldmodifiable=&modifiable
	let &modifiable=1
	if !exists("b:editHex") || !b:editHex
		" save old options
		let b:oldft=&ft
		let b:oldbin=&bin
		" set new options
		setlocal binary " make sure it overrides any textwidth, etc.
		let &ft="xxd"
		" set status
		let b:editHex=1
		" switch to hex editor
		%!xxd
	else
		" restore old options
		let &ft=b:oldft
		if !b:oldbin
			setlocal nobinary
		endif
		" set status
		let b:editHex=0
		" return to normal editing
		%!xxd -r
	endif
	" restore values for modified and read only state
	let &mod=l:modified
	let &readonly=l:oldreadonly
	let &modifiable=l:oldmodifiable
endfunction

" autocmds to automatically enter hex mode and handle file writes properly
if has("autocmd")
	" vim -b : edit binary using xxd-format!
	augroup Binary
		autocmd!

		" set binary option for all binary files before reading them
		autocmd BufReadPre *.bin,*.hex setlocal binary

		" if on a fresh read the buffer variable is already set, it's wrong
		autocmd BufReadPost *
					\ if exists('b:editHex') && b:editHex |
					\   let b:editHex = 0 |
					\ endif

		" convert to hex on startup for binary files automatically
		autocmd BufReadPost *
					\ if &binary | Hexmode | endif

		" When the text is freed, the next time the buffer is made active it will
		" re-read the text and thus not match the correct mode, we will need to
		" convert it again if the buffer is again loaded.
		autocmd BufUnload *
					\ if getbufvar(expand("<afile>"), 'editHex') == 1 |
					\   call setbufvar(expand("<afile>"), 'editHex', 0) |
					\ endif

		" before writing a file when editing in hex mode, convert back to non-hex
		autocmd BufWritePre *
					\ if exists("b:editHex") && b:editHex && &binary |
					\  let oldro=&ro | let &ro=0 |
					\  let oldma=&ma | let &ma=1 |
					\  silent exe "%!xxd -r" |
					\  let &ma=oldma | let &ro=oldro |
					\  unlet oldma | unlet oldro |
					\ endif

		" after writing a binary file, if we're in hex mode, restore hex mode
		autocmd BufWritePost *
					\ if exists("b:editHex") && b:editHex && &binary |
					\  let oldro=&ro | let &ro=0 |
					\  let oldma=&ma | let &ma=1 |
					\  silent exe "%!xxd" |
					\  exe "set nomod" |
					\  let &ma=oldma | let &ro=oldro |
					\  unlet oldma | unlet oldro |
					\ endif
	augroup END
endif
