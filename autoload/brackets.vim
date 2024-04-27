" argument: the number of characters you want to get
function! s:get_prev_char(length) abort
    let cursor_col = col('.') - 1
    let line = getline('.')
    let start_col = max([0, cursor_col - a:length])
    return line[start_col : cursor_col - 1]
endfunction

function! s:get_prev_string() abort
    let cursor_col = col('.') - 1
    let line = getline('.')
    return line[0 : cursor_col - 1]
endfunction

" argument: the number of characters you want to get
function! s:get_next_char(length) abort
    let cursor_col = col('.') - 1
    let line = getline('.')
    let end_col = min([len(line) - 1, cursor_col + a:length - 1])
    return line[cursor_col : end_col]
endfunction

function! s:get_next_string() abort
    let cursor_col = col('.') - 1
    let line = getline('.')
    return line[cursor_col : len(line)]
endfunction

" Alphabetical or not?
function! s:is_alphabet(char) abort
	return (a:char =~ "[a-zA-Z]")
endfunction

" Full-width char or not?
function! s:is_full_width(char) abort
	return (a:char =~ "[^\x01-\x7E]")
endfunction

" Number or not?
function! s:is_num(char) abort
	return (a:char =~ "[0-9]")
endfunction

" Open bracketsor or not?
function! s:is_open_parenthesis(char) abort
	return (a:char == "{" || a:char == "[" || a:char == "(" || a:char == "<")
endfunction

" Close bracket or not?
function! s:is_close_parenthesis(char) abort
	return (a:char == "}" || a:char == "]" || a:char == ")" || a:char == ">")
endfunction

" Quote or not?
function! s:is_quote(char) abort
	return (a:char == "'" || a:char == '"' || a:char == "`")
endfunction

" Empty or not?
function! s:is_empty(char) abort
    return a:char == ' ' || a:char == ''
endfunction

" Is the parentheses pair or not?
function! s:is_parentheses_pair(prev_char,next_char) abort
	let l:cursor_is_inside_parentheses1 = (a:prev_char == "{" && a:next_char == "}")
	let l:cursor_is_inside_parentheses2 = (a:prev_char == "[" && a:next_char == "]")
	let l:cursor_is_inside_parentheses3 = (a:prev_char == "(" && a:next_char == ")")
	let l:cursor_is_inside_parentheses4 = (a:prev_char == "<" && a:next_char == ">")
	return (l:cursor_is_inside_parentheses1 || l:cursor_is_inside_parentheses2 || l:cursor_is_inside_parentheses3 || l:cursor_is_inside_parentheses4)
endfunction

" Inside a quote or not?
function! s:is_quote_pair(prev_char, next_char) abort
	let l:exists_quote = (a:prev_char == "'" && a:next_char == "'")
	let l:exists_double_quote = (a:prev_char == "\"" && a:next_char == "\"")
	let l:exists_back_quote = (a:prev_char == "`" && a:next_char == "`")
    return (l:exists_quote || l:exists_double_quote || l:exists_back_quote)
endfunction

" Is the same quote pair or not?
function! s:is_the_same_quote_pair(char, prev_char, next_char) abort
    return  (a:prev_char == a:char && a:next_char == a:char)
endfunction

" Entering Parentheses key
function! brackets#InputParentheses(parenthesis) abort
	let l:prev_char = s:get_prev_char(1)
	let l:next_char = s:get_next_char(1)
	let l:parentheses = { "{": "}", "[": "]", "(": ")", "<": ">" }

	if ! s:is_parentheses_pair(l:prev_char, l:next_char)
            \ && ! s:is_quote_pair(l:prev_char, l:next_char)
            \ && ! s:is_empty(l:next_char)
	    return a:parenthesis
	endif
	return a:parenthesis.l:parentheses[a:parenthesis]."\<LEFT>"
endfunction

" Entering close bracket key
function! brackets#InputCloseParenthesis(parenthesis) abort
	let l:next_char = s:get_next_char(1)
	if l:next_char == a:parenthesis
		return "\<RIGHT>"
	endif
	return a:parenthesis
endfunction

" Entering the quote key
function! brackets#InputQuote(quote) abort
	let l:prev_char = s:get_prev_char(1)
	let l:next_char = s:get_next_char(1)
	let l:prev_two_char = s:get_prev_char(2)
    " return '('.l:prev_char.')('.l:next_char.')'

	if s:is_the_same_quote_pair(a:quote, l:prev_char, l:next_char)
		return "\<RIGHT>"

    " prev char is empty
    elseif s:is_empty(l:prev_char) && ! s:is_empty(l:next_char)
        if ! s:is_close_parenthesis(l:next_char)
                \ || l:prev_two_char != ', '
            return a:quote
        endif

    " inside chars
    elseif ! s:is_empty(l:prev_char) && ! s:is_empty(l:next_char)
        if ! s:is_parentheses_pair(l:prev_char, l:next_char)
            if l:prev_char != ',' || ! s:is_close_parenthesis(l:next_char)
                return a:quote
            endif
        endif

    " next char is empty
    elseif ! s:is_empty(l:prev_char) && s:is_empty(l:next_char)
        if l:prev_char != '='
                \ && ! s:is_open_parenthesis(l:prev_char)
                \ && l:prev_char != ','
            return a:quote
        endif
	endif

	return a:quote.a:quote."\<LEFT>"
endfunction

" Entering the comma key
function! brackets#InputComma(comma) abort
	let l:next_char = s:get_next_char(1)
	let l:prev_char = s:get_prev_char(1)
    if s:is_quote(l:prev_char)
            \ && (s:is_empty(l:next_char) || s:is_close_parenthesis(l:next_char))
        return ", ".l:prev_char.l:prev_char."\<left>"
    else
        return ","
    endif
endfunction

" Entering the dollar key
function! brackets#InputDollar(dollar) abort
    if &ft == 'sh' || &ft == 'fnc' || &ft == 'zsh' || &ft == 'bash'
    	let l:prev_char = s:get_prev_char(1)
    	let l:next_char = s:get_next_char(1)
        if s:is_empty(l:prev_char) && s:is_empty(l:next_char)
            return "${}\<left>"
        endif
    endif
    return a:dollar
endfunction

" Entering the <CR> key
function! brackets#InputCR() abort
	let l:next_char = s:get_next_char(1)
	let l:prev_char = s:get_prev_char(1)
	if s:is_parentheses_pair(l:prev_char,l:next_char)
		return "\<CR>\<ESC>\<S-o>"
	else
		return "\<CR>"
	endif
endfunction

" Entering the <SPACE> key
function! brackets#InputSpace() abort
	let l:prev_char = s:get_prev_char(1)
	let l:next_char = s:get_next_char(1)
    let l:prev_string = s:get_prev_string()
    let l:next_string = s:get_next_string()

	if s:is_parentheses_pair(l:prev_char,l:next_char)
		return "\<Space>\<Space>\<LEFT>"
	endif

    if l:prev_string =~ '\S[\!\=\+\-]=$' || l:prev_string =~ '\S\=\~$'
        return "\<left>\<left>\<Space>\<right>\<right>\<Space>"
    elseif l:next_string =~ '^=[\=\~]\S' || l:next_string =~ '^[\!\+\-]=\S'
        return "\<space>\<right>\<right>\<Space>"
    elseif l:prev_string =~ '\S=$' && l:prev_string !~ '==$'
        return "\<left>\<space>\<right>\<Space>"
    elseif l:next_string =~ '^=\S' && l:next_string !~ '^=='
        return "\<space>\<right>\<Space>"
    endif

	return "\<Space>"
endfunction

" Entering the <BS> key
function! brackets#InputBS() abort
	let l:prev_char = s:get_prev_char(1)
	let l:next_char = s:get_next_char(1)

    if s:is_parentheses_pair(l:prev_char, l:next_char)
        return "\<right>\<BS>\<BS>"
    endif

    if s:get_prev_string() =~ '\s==\s$'
        return "\<BS>\<BS>\<BS>\<BS>=="
    elseif s:is_empty(l:prev_char) && s:get_next_string() =~ '^==\s'
        return "\<right>\<right>\<right>\<BS>\<BS>\<BS>\<BS>=="
    endif

    if s:get_prev_string() =~ '\s=\s$'
        return "\<BS>\<BS>\<BS>="
    elseif s:is_empty(l:prev_char) && s:get_next_string() =~ '^=\s'
        return "\<right>\<right>\<BS>\<BS>\<BS>="
    endif

	if s:get_prev_string() =~ '[\(\[{]\s$' && s:get_next_string() =~ '^ [\)\]}>]'
		return "\<BS>\<RIGHT>\<BS>"
	endif

	return "\<BS>"
endfunction

