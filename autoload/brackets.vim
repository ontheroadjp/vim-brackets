" Get the next string after the cursor
" argument: the number of characters you want to get
function! s:get_next_string(length) abort
	let l:str = ""
	for i in range(0, a:length-1)
		let l:str = l:str.getline(".")[col(".")-1+i]
	endfor
	return l:str
endfunction

" Get the previous string after the cursor
" argument: the number of characters you want to get
function! s:get_prev_string(length) abort
	let l:str = ""
	for i in range(0, a:length-1)
		let l:str = getline(".")[col(".")-2-i].l:str
	endfor
	return l:str
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

" Inside the brackets or not?
function! s:is_inside_parentheses(prev_char,next_char) abort
	let l:cursor_is_inside_parentheses1 = (a:prev_char == "{" && a:next_char == "}")
	let l:cursor_is_inside_parentheses2 = (a:prev_char == "[" && a:next_char == "]")
	let l:cursor_is_inside_parentheses3 = (a:prev_char == "(" && a:next_char == ")")
	let l:cursor_is_inside_parentheses4 = (a:prev_char == "<" && a:next_char == ">")
	return (l:cursor_is_inside_parentheses1 || l:cursor_is_inside_parentheses2 || l:cursor_is_inside_parentheses3 || l:cursor_is_inside_parentheses4)
endfunction

" Inside a quote or not?
function! s:is_inside_quote(prev_char, next_char) abort
	let l:exists_quote = (a:prev_char == "'" && a:next_char == "'")
	let l:exists_double_quote = (a:prev_char == "\"" && a:next_char == "\"")
	let l:exists_back_quote = (a:prev_char == "`" && a:next_char == "`")
    return (l:exists_quote || l:exists_double_quote || l:exists_back_quote)
endfunction

" Inside the same quote or not?
function! s:is_inside_the_same_quote(char, prev_char, next_char) abort
    return  (a:prev_char == a:char && a:next_char == a:char)
endfunction

" Entering Parentheses key
function! brackets#InputParentheses(parenthesis) abort
	let l:prev_char = s:get_prev_string(1)
	let l:next_char = s:get_next_string(1)
	let l:parentheses = { "{": "}", "[": "]", "(": ")", "<": ">" }

	if ! s:is_inside_parentheses(l:prev_char, l:next_char)
            \ && ! s:is_inside_quote(l:prev_char, l:next_char)
            \ && ! s:is_empty(l:next_char)
	    return a:parenthesis
	endif
	return a:parenthesis.l:parentheses[a:parenthesis]."\<LEFT>"
endfunction

" Entering close bracket key
function! brackets#InputCloseParenthesis(parenthesis) abort
	let l:next_char = s:get_next_string(1)

	if l:next_char == a:parenthesis
		return "\<RIGHT>"
	endif
	return a:parenthesis
endfunction

" Entering the quote key
function! brackets#InputQuote(quote) abort
	let l:next_char = s:get_next_string(1)
	let l:prev_char = s:get_prev_string(1)

	if s:is_inside_the_same_quote(a:quote, l:prev_char, l:next_char)
		return "\<RIGHT>"
	elseif s:is_close_parenthesis(l:prev_char)
		return a:quote

    " in case of begining of a line
    elseif s:is_empty(l:prev_char) && ! s:is_empty(l:next_char)
            return a:quote

    " in case of inside chars
    elseif ! s:is_empty(l:prev_char) && ! s:is_empty(l:next_char)
    	if ! s:is_inside_parentheses(l:prev_char, l:next_char)
            return a:quote
        endif

    " in case of end of a line
    elseif ! s:is_empty(l:prev_char) && s:is_empty(l:next_char)
        if l:prev_char != '=' && ! s:is_open_parenthesis(l:prev_char)
            return a:quote
        endif
	endif


	return a:quote.a:quote."\<LEFT>"
endfunction

" Entering the comma key
function! brackets#InputComma(comma) abort
	let l:next_char = s:get_next_string(1)
	let l:prev_char = s:get_prev_string(1)
	let l:next_char_is_empty = (l:next_char == "")
	let l:next_char_is_space = (l:next_char == " ")
	let l:next_char_is_close_parenthesis = s:is_close_parenthesis(l:next_char)

    if (l:prev_char == "\"" || l:prev_char == "'") && (l:next_char_is_space || l:next_char_is_empty || l:next_char_is_close_parenthesis)
        return ", ".l:prev_char.l:prev_char."\<left>"
    else
        return ","
    endif
endfunction

" Entering the dollar key
function! brackets#InputDollar(dollar) abort
	let l:prev_char = s:get_prev_string(1)
	let l:next_char = s:get_next_string(1)
    if s:is_empty(l:prev_char) && s:is_empty(l:next_char)
        if &ft == 'sh' || &ft == 'fnc' || &ft == 'zsh' || &ft == 'bash'
            return a:dollar."{}\<left>"
        endif
    endif
    return a:dollar
endfunction

" Entering the <CR> key
function! brackets#InputCR() abort
	let l:next_char = s:get_next_string(1)
	let l:prev_char = s:get_prev_string(1)
	let l:cursor_is_inside_parentheses = s:is_inside_parentheses(l:prev_char,l:next_char)

	if l:cursor_is_inside_parentheses
		return "\<CR>\<ESC>\<S-o>"
	else
		return "\<CR>"
	endif
endfunction

" Entering the <SPACE> key
function! brackets#InputSpace() abort
	let l:prev_char = s:get_prev_string(1)
	let l:next_char = s:get_next_string(1)
	let l:prev_two_string = s:get_prev_string(2)
	let l:next_two_string = s:get_next_string(2)
	let l:prev_three_string = s:get_prev_string(3)
	let l:next_three_string = s:get_next_string(3)
	let l:cursor_is_inside_parentheses = s:is_inside_parentheses(l:prev_char,l:next_char)

	if l:cursor_is_inside_parentheses
		return "\<Space>\<Space>\<LEFT>"
	endif

    if l:prev_two_string == "==" && l:prev_three_string != " =="
        return "\<BS>\<BS>\<Space>==\<Space>"
    elseif l:next_two_string == "==" && l:next_three_string != "== "
        return "\<right>\<right>\<BS>\<BS>\<Space>==\<Space>"
    elseif l:prev_two_string == "!=" && l:prev_three_string != " !="
        return "\<BS>\<BS>\<Space>!=\<Space>"
    elseif l:next_two_string == "!=" && l:next_three_string != "!= "
        return "\<right>\<right>\<BS>\<BS>\<Space>!=\<Space>"
    elseif l:prev_two_string == "+=" && l:prev_three_string != " +="
        return "\<BS>\<BS>\<Space>+=\<Space>"
    elseif l:next_two_string == "+=" && l:next_three_string != "+= "
        return "\<right>\<right>\<BS>\<BS>\<Space>+=\<Space>"
    elseif l:prev_two_string == "-=" && l:prevThreeString != " -="
        return "\<BS>\<BS>\<Space>-=\<Space>"
    elseif l:next_two_string == "-=" && l:next_three_string != "-= "
        return "\<right>\<right>\<BS>\<BS>\<Space>-=\<Space>"
    endif

    if l:prev_char == "="
                \ && l:prev_two_string != " ="
                \ && l:prev_two_string != "!="
                \ && l:prev_two_string != "=="
                \ && l:prev_two_string != "+="
                \ && l:prev_two_string != "-="
        return "\<BS>\<Space>=\<Space>"
    endif
    if l:next_char == "="
                \ && l:next_two_string != "= "
                \ && l:next_two_string != "=="
                \ && l:next_two_string != "=~"
        return "\<right>\<BS>\<Space>=\<Space>"
    endif
	return "\<Space>"
endfunction

" Entering the <BS> key
function! brackets#InputBS() abort
	let l:prev_char = s:get_prev_string(1)
	let l:next_char = s:get_next_string(1)
	let l:prev_two_string = s:get_prev_string(2)
	let l:next_two_string = s:get_next_string(2)
	let l:prev_three_string = s:get_prev_string(3)
	let l:next_three_string = s:get_next_string(3)
	let l:prev_four_string = s:get_prev_string(4)
	let l:next_four_string = s:get_next_string(4)
	let l:cursor_is_inside_parentheses = s:is_inside_parentheses(l:prev_char,l:next_char)
    let l:cursor_is_inside_quote = s:is_inside_quote(l:prev_char, l:next_char)
	let l:cursor_is_inside_space1 = (l:prev_two_string == "{ " && l:next_two_string == " }")
	let l:cursor_is_inside_space2 = (l:prev_two_string == "[ " && l:next_two_string == " ]")
	let l:cursor_is_inside_space3 = (l:prev_two_string == "( " && l:next_two_string == " )")
	let l:cursor_is_inside_space4 = (l:prev_two_string == "< " && l:next_two_string == " >")
	let l:cursor_is_inside_space = (l:cursor_is_inside_space1 || l:cursor_is_inside_space2 || l:cursor_is_inside_space3 || l:cursor_is_inside_space4)

    if l:prev_four_string == ' == '
        return "\<BS>\<BS>\<BS>\<BS>=="
    elseif l:next_three_string == '== '
        return "\<right>\<right>\<right>\<BS>\<BS>\<BS>\<BS>=="
    endif

    if l:prev_three_string == ' = '
        return "\<BS>\<BS>\<BS>="
    elseif l:next_two_string == '= '
        return "\<right>\<right>\<BS>\<BS>\<BS>="
    endif

	if l:cursor_is_inside_parentheses || l:cursor_is_inside_quote || l:cursor_is_inside_space
		return "\<BS>\<RIGHT>\<BS>"
	endif

	return "\<BS>"
endfunction

