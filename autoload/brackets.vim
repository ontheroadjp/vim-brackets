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

" Prev/next char is alphabetical or not?
function! s:is_alphabet(char) abort
	return (a:char =~ "[a-zA-Z]")
endfunction

" Prev/next char is full-width char or not?
function! s:is_full_width(char) abort
	return (a:char =~ "[^\x01-\x7E]")
endfunction

" Prev/next char is the number or not?
function! s:is_num(char) abort
	return (a:char =~ "[0-9]")
endfunction

" Prev/Next char is the open bracketsor not?
function! s:is_open_parenthesis(char) abort
	return (a:char == "{" || a:char == "[" || a:char == "(" || a:char == "<")
endfunction

" Prev/Next char is the close bracket or not?
function! s:is_close_parenthesis(char) abort
	return (a:char == "}" || a:char == "]" || a:char == ")" || a:char == ">")
endfunction

" Prev/Next char is the quote or not?
function! s:is_quote(char) abort
	return (a:char == "'" || a:char == '"' || a:char == "`")
endfunction

" Is a cursor inside the brackets or not?
function! s:is_inside_parentheses(prev_char,next_char) abort
	let l:cursor_is_inside_parentheses1 = (a:prev_char == "{" && a:next_char == "}")
	let l:cursor_is_inside_parentheses2 = (a:prev_char == "[" && a:next_char == "]")
	let l:cursor_is_inside_parentheses3 = (a:prev_char == "(" && a:next_char == ")")
	let l:cursor_is_inside_parentheses4 = (a:prev_char == "<" && a:next_char == ">")
	return (l:cursor_is_inside_parentheses1 || l:cursor_is_inside_parentheses2 || l:cursor_is_inside_parentheses3 || l:cursor_is_inside_parentheses4)
endfunction

" Is the cursor inside the quote or not?
function! s:is_inside_quote(prev_char, next_char) abort
	let l:exists_quote = (a:prev_char == "'" && a:next_char == "'")
	let l:exists_double_quote = (a:prev_char == "\"" && a:next_char == "\"")
	let l:exists_back_quote = (a:prev_char == "`" && a:next_char == "`")
    return (l:exists_quote || l:exists_double_quote || l:exists_back_quote)
endfunction

function! s:is_empty(char) abort
    return a:char == ' ' || a:char == ''
endfunction

function! s:is_close_parenthesis(char) abort
    return (a:char == "}" || a:char == "]" || a:char == ")" || a:char == ">")
endfunction

" Entering Parentheses key
function! brackets#InputParentheses(parenthesis) abort
	let l:prev_char = s:get_prev_string(1)
	let l:next_char = s:get_next_string(1)
	let l:parentheses = { "{": "}", "[": "]", "(": ")", "<": ">" }

	if ! s:is_inside_parentheses(l:prev_char, l:next_char) && ! s:is_empty(l:next_char)
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
	let l:cursor_is_inside_the_same_quotes = (l:prev_char == a:quote && l:next_char == a:quote)

	if l:cursor_is_inside_the_same_quotes
		return "\<RIGHT>"
	elseif s:is_close_parenthesis(l:prev_char) || l:prev_char == a:quote || l:next_char == a:quote
		return a:quote
	else
		return a:quote.a:quote."\<LEFT>"
	endif
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
function! brackets#InputDallar(dallar) abort
    if &filetype ==# 'sh' || &filetype ==# 'fnc'
        return a:dallar."{}\<left>"
    else
        return a:dallar
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

