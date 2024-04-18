# vim-brackets

This is a vim plugin that completes parentheses and brackets.

It completes appropriately according to the context before and after the cursor position. It also changes the behavior of the space and backspace keys for parentheses and brackets according to the context.

## Install

No special configuration is required, just download the plug-in. The following is a case of installing with vim-plug.

```vim
Plug 'ontheroad/vim-brackets'
```

## How does it work?

May or may not be completed depending on the context before and after.

### Parentheses rules

The conditions for functioning are as follows

- When a cursor is inside the ``()``, ``{}``, ``[]`` and ``<>``

- When a cursor is inside the ``""``, ``''`` and ````

- When right side of a cursor is empty

It will work ...

(``|`` is a cursor position)

| before | input | after    | activate |
|:------ |:----- | -------- | -------- |
| \|     | (     | (\|)     | yes      |
| (\|)   | )     | ()\|     |          |
| (\|)   | (     | ((\|))   | yes      |
| "\|"   | (     | "(\|)"   | yes      |
| \|hoge | (     | (\|hoge  |          |
| hoge\| | (     | hoge(\|) | yes      |
| ho\|ge | (     | ho(\|ge  |          |

Same as ``{}``, ``[]`` and ``<>``

### Brackets

The conditions for functioning are as follows

- When a cursor is inside the `()`, `{}`, `[]` and `<>`

- When a cursor is inside the `""`, `''` and ````

- When both sides of the cursor are blankExcept as noted above

| before | input | after   | activate |
|:------ |:----- |:------- | -------- |
| \|     | "     | "\|"    | yes      |
| "\|"   | "     | ""\|    |          |
| hoge\| | "     | hoge"\| |          |
| \|hoge | "     | "\|hoge |          |
| ho\|ge | "     | ho"\|ge |          |
| (\|)   | "     | ("\|")  | yes      |
| [\|]   | "     | ["\|"]  | yes      |
| <\|>   | "     | <"\|">  | yes      |
| {\|}   | "     | {"\|"}  | yes      |

### <BS> key

| before      | input | after     |
| ----------- | ----- | --------- |
| (\|)        | <BS>  | \|        |
| ( \| )      | <BS>  | (\|)      |
| xxx \|= xxx | <BS>  | xxx\|=xxx |
| xxx = \|xxx | <BS>  | xxx=\|xxx |

### <SPACE> key

| before    | input   | after       |
| --------- | ------- | ----------- |
| (\|)      | <SPACE> | ( \| )      |
| xxx\|=xxx | <SPACE> | xxx \|= xxx |
| xxx=\|xxx | <SPACE> | xxx =\| xxx |
