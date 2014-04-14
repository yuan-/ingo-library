" ingo/escape/file.vim: Additional escapings of filespecs.
"
" DEPENDENCIES:
"   - ingo/os.vim autoload script
"
" Copyright: (C) 2013-2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.018.002	21-Mar-2014	Add ingo#escape#file#wildcardescape().
"   1.012.001	08-Aug-2013	file creation

function! ingo#escape#file#bufnameescape( filespec, ... )
"*******************************************************************************
"* PURPOSE:
"   Escape a normal filespec syntax so that it can be used for the bufname(),
"   bufnr(), bufwinnr(), ... commands.
"   Ensure that there are no double (back-/forward) slashes inside the path; the
"   anchored pattern doesn't match in those cases!
"
"* ASSUMPTIONS / PRECONDITIONS:
"	? List of any external variable, control, or other element whose state affects this procedure.
"* EFFECTS / POSTCONDITIONS:
"	? List of the procedure's effect on each external variable, control, or other element.
"* INPUTS:
"   a:filespec	    Normal filespec
"   a:isFullMatch   Optional flag whether only the full filespec should be
"		    matched (default=1). If 0, the escaped filespec will not be
"		    anchored.
"* RETURN VALUES:
"   Filespec escaped for the buf...() commands.
"*******************************************************************************
    let l:isFullMatch = (a:0 ? a:1 : 1)

    " For a full match, the passed a:filespec must be converted to a full
    " absolute path (with symlinks resolved, just like Vim does on opening a
    " file) in order to match.
    let l:escapedFilespec = (l:isFullMatch ? resolve(fnamemodify(a:filespec, ':p')) : a:filespec)

    " Backslashes are converted to forward slashes, as the comparison is done with
    " these on all platforms, anyway (cp. :help file-pattern).
    let l:escapedFilespec = tr(l:escapedFilespec, '\', '/')

    " Special file-pattern characters must be escaped: [ escapes to [[], not \[.
    let l:escapedFilespec = substitute(l:escapedFilespec, '[\[\]]', '[\0]', 'g')

    " The special filenames '#' and '%' need not be escaped when they are anchored
    " or occur within a longer filespec.
    let l:escapedFilespec = escape(l:escapedFilespec, '?*')

    " I didn't find any working escaping for {, so it is replaced with the ?
    " wildcard.
    let l:escapedFilespec = substitute(l:escapedFilespec, '[{}]', '?', 'g')

    if l:isFullMatch
	" The filespec must be anchored to ^ and $ to avoid matching filespec
	" fragments.
	return '^' . l:escapedFilespec . '$'
    else
	return l:escapedFilespec
    endif
endfunction

function! ingo#escape#file#fnameunescape( exfilespec, ... )
"*******************************************************************************
"* PURPOSE:
"   Converts the passed a:exfilespec to the normal filespec syntax (i.e. no
"   escaping of Ex special chars like [%#]). The normal syntax is required by
"   Vim functions such as filereadable(), because they do not understand the
"   escaping for Ex commands.
"   Note: On Windows, fnamemodify() doesn't convert path separators to
"   backslashes. We don't force that neither, as forward slashes work just as
"   well and there is even less potential for problems.
"* ASSUMPTIONS / PRECONDITIONS:
"	? List of any external variable, control, or other element whose state affects this procedure.
"* EFFECTS / POSTCONDITIONS:
"	? List of the procedure's effect on each external variable, control, or other element.
"* INPUTS:
"   a:exfilespec    Escaped filespec to be passed as a {file} argument to an Ex
"		    command.
"   a:isMakeFullPath	Flag whether the filespec should also be expanded to a
"			full path, or kept in whatever form it currently is.
"* RETURN VALUES:
"   Unescaped, normal filespec.
"*******************************************************************************
    let l:isMakeFullPath = (a:0 ? a:1 : 0)
    return fnamemodify( a:exfilespec, ':gs+\\\([ \t\n*?`%#''"|!<' . (ingo#os#IsWinOrDos() ? '' : '[{$\') . ']\)+\1+' . (l:isMakeFullPath ? ':p' : ''))
endfunction

function! ingo#escape#file#autocmdescape( filespec )
"******************************************************************************
"* PURPOSE:
"   Escape a normal filespec syntax so that it can be used in an :autocmd.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:filespec	    Normal filespec or file pattern.
"* RETURN VALUES:
"   Escaped filespec to be passed as a {pat} argument to :autocmd.
"******************************************************************************
    let l:filespec = a:filespec

    if ingo#os#IsWinOrDos()
	" Windows: Replace backslashes in filespec with forward slashes.
	" Otherwise, the autocmd won't match the filespec.
	let l:filespec = tr(l:filespec, '\', '/')
    endif

    " Escape spaces in filespec.
    " Otherwise, the autocmd will be parsed wrongly, taking only the first part
    " of the filespec as the file and interpreting the remainder of the filespec
    " as part of the command.
    return escape(l:filespec, ' ')
endfunction

function! ingo#escape#file#wildcardescape( filespec )
"******************************************************************************
"* PURPOSE:
"   Escape a normal filespec for (literal) use in glob(). Escapes [, ?, * and
"   **.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:filespec	    Normal filespec
"* RETURN VALUES:
"   Escaped filespec to be passed as an argument to glob().
"******************************************************************************
    return substitute(escape(a:filespec, '?*'), '[[]', '[[]', 'g')
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
