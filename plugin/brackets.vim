" Don't load if it's already loaded or disabled by user
if !get(g:,'brackets_enabled', 1) | finish | endif
if exists('g:loaded_brackets') | finish | endif
let g:loaded_brackets = 1

let g:bracket#snipmate_cr_trigger_enable = 1
let g:bracket#asyncomplete_cr_trigger_enable = 1

if get(g:, 'brackets_map_parentheses', 1)
    inoremap <silent> <expr> { brackets#InputParentheses("{")
    inoremap <silent> <expr> [ brackets#InputParentheses("[")
    inoremap <silent> <expr> ( brackets#InputParentheses("(")
    inoremap <silent> <expr> < brackets#InputParentheses("<")
    inoremap <silent> <expr> } brackets#InputCloseParenthesis("}")
    inoremap <silent> <expr> ] brackets#InputCloseParenthesis("]")
    inoremap <silent> <expr> ) brackets#InputCloseParenthesis(")")
    inoremap <silent> <expr> > brackets#InputCloseParenthesis(">")
endif

if get(g:, 'brackets_map_quotes', 1)
    inoremap <silent> <expr> ' brackets#InputQuote("'")
    inoremap <silent> <expr> " brackets#InputQuote('"')
    inoremap <silent> <expr> ` brackets#InputQuote("`")
endif

if get(g:, 'brackets_map_comma', 1)
    inoremap <silent> <expr> , brackets#InputComma(",")
endif

if get(g:, 'brackets_map_dollar', 1)
    inoremap <silent> <expr> $ brackets#InputDollar("$")
endif

if get(g:, 'brackets_map_cr', 1)
    inoremap <silent> <expr> <CR> brackets#InputCR()
endif

if get(g:, 'brackets_map_space', 1)
    inoremap <silent> <expr> <Space> brackets#InputSpace()
endif

if get(g:, 'brackets_map_bs', 1)
    inoremap <silent> <expr> <BS> brackets#InputBS()
endif

