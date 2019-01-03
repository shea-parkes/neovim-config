
"""""""""""""""""""""""""""""""""""""""""""""
"" My poor man's replacement for vim-slime ""
"""""""""""""""""""""""""""""""""""""""""""""
let g:my_active_terminal_job_id = -1

function! LaunchTerminal() range
  silent exe "normal! :vsplit\n"
  silent exe "normal! :terminal\n"
  exe "normal! G\n"
  call SetActiveTerminalJobID()
endfunction

function! LaunchIPython() range
  call LaunchTerminal()
  call jobsend(g:my_active_terminal_job_id, "ipython\r")
endfunction

function! SetActiveTerminalJobID()
  let g:my_active_terminal_job_id = b:terminal_job_id
  echom "Active terminal job ID set to " . g:my_active_terminal_job_id
endfunction

function! SendToTerminal() range
  " Yank the last selection into register "a"
  silent exe 'normal! gv"ay'
  " Send register "a" into the terminal
  call jobsend(g:my_active_terminal_job_id, @a)
  " Pause a moment, then send a carriage return to trigger its evaluation
  sleep 210ms
  call jobsend(g:my_active_terminal_job_id, "\r")
endfunction

function! SendNudgeToTerminal() range
  " Send in a nudge.  Can help trigger IPython evaluation
  call jobsend(g:my_active_terminal_job_id, "\r")
endfunction
