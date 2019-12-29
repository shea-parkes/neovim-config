"""
Prepare an IPython interpreter for REPL use.

Note: shell.write() is depreciated for interactive shells; just print.
"""
import IPython
import IPython.terminal.magics

N_LINES_GLIMPSE = 2
IPYTHON_SHELL = IPython.get_ipython()
TERMINAL_MAGICS = IPython.terminal.magics.TerminalMagics(IPYTHON_SHELL)

def run_from_clipboard():
    """Run code from the clipboard the way I want to"""
    code_raw = IPYTHON_SHELL.hooks.clipboard_get()
    code_split = code_raw.rstrip().split('\n')

    code_to_echo = []
    code_to_echo.append('# <<<< Grabbed {} line{} from the clipboard:'.format(
        len(code_split),
        's' if len(code_split) > 1 else '',
    ))
    if len(code_split) <= (2*N_LINES_GLIMPSE + 1):
        code_to_echo.extend(code_split)
    else:
        code_to_echo.extend(code_split[:N_LINES_GLIMPSE])
        code_to_echo.append('# ... omitting {} lines ...'.format(
            len(code_split) - 2*N_LINES_GLIMPSE,
        ))
        code_to_echo.extend(code_split[-N_LINES_GLIMPSE:])
    code_to_echo.append('# >>>>')
    print(IPYTHON_SHELL.pycolorize('\n'.join(code_to_echo)))

    TERMINAL_MAGICS.store_or_execute('\n'.join(code_split), None)
