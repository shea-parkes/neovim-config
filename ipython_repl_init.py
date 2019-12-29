"""
Prepare an IPython interpreter for REPL use.

Note: shell.write() is depreciated for interactive shells; just print.
"""
import IPython
import IPython.terminal.magics

N_LINES_SHOWN = 3
IPYTHON_SHELL = IPython.get_ipython()
TERMINAL_MAGICS = IPython.terminal.magics.TerminalMagics(IPYTHON_SHELL)

def run_from_clipboard():
    """Run code from the clipboard the way I want to"""
    code = IPYTHON_SHELL.hooks.clipboard_get()
    if not code.endswith('\n'):
        code += '\n'
    n_lines = code.count('\n')

    print('..Grabbed {} lines from the clipboard..'.format(n_lines))
    header_lines = '\n'.join(code.split('\n')[:N_LINES_SHOWN])
    print(IPYTHON_SHELL.pycolorize(header_lines))
    if n_lines > N_LINES_SHOWN:
        print('...\n')
    TERMINAL_MAGICS.store_or_execute(code, None)
