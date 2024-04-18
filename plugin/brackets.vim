if exists('g:loaded_brackets')
    finish
endif
let g:loaded_brackets = 1

inoremap <expr> { brackets#InputParentheses("{")
inoremap <expr> [ brackets#InputParentheses("[")
inoremap <expr> ( brackets#InputParentheses("(")
inoremap <expr> < brackets#InputParentheses("<")
inoremap <expr> } brackets#InputCloseParenthesis("}")
inoremap <expr> ] brackets#InputCloseParenthesis("]")
inoremap <expr> ) brackets#InputCloseParenthesis(")")
inoremap <expr> > brackets#InputCloseParenthesis(">")
inoremap <expr> ' brackets#InputQuote("\'")
inoremap <expr> " brackets#InputQuote("\"")
inoremap <expr> ` brackets#InputQuote("\`")
inoremap <expr> , brackets#InputComma("\,")
inoremap <expr> $ brackets#InputDallar("\$")
inoremap <expr> <CR> brackets#InputCR()
inoremap <expr> <Space> brackets#InputSpace()
inoremap <expr> <BS> brackets#InputBS()

