c = get_config()

c.IPKernelApp.matplotlib = 'inline'
c.InlineBackend.figure_format='retina'
c.InteractiveShell.ast_node_interactivity = "all"
c.InteractiveShellApp.extensions = ['autoreload']
c.InteractiveShellApp.exec_lines = ['%autoreload 2']
c.InteractiveShellApp.exec_lines.append("print('autoreload enabled.')")

import warnings
warnings.filterwarnings("ignore", message="numpy.dtype size changed")
