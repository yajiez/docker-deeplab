# Configuration file for jupyter-notebook.

c.NotebookApp.open_browser = False
#c.NotebookApp.browser = ''

## The full path to an SSL/TLS certificate file.
# c.NotebookApp.certfile = '/path/to/mycert.pem'
# c.NotebookApp.keyfile = '/path/to/mycert.pem'


#c.NotebookApp.enable_mathjax = True
#c.NotebookApp.mathjax_config = 'TeX-AMS-MML_HTMLorMML-full,Safe'
#c.NotebookApp.mathjax_url = ''

## (bytes/sec) Maximum rate at which stream output can be sent on iopub before
#  they are limited.
#c.NotebookApp.iopub_data_rate_limit = 1000000

## (msgs/sec) Maximum rate at which messages can be sent on iopub before they are
#  limited.
#c.NotebookApp.iopub_msg_rate_limit = 1000

## The IP address the notebook server will listen on.
c.NotebookApp.ip = '0.0.0.0'
c.NotebookApp.port = 8889
#c.NotebookApp.port_retries = 50

## The directory to use for notebooks and kernels.
# c.NotebookApp.notebook_dir = '/'


## Hashed password to use for web authentication.
#
#  To generate, type in a python/IPython shell:
#
#    from notebook.auth import passwd; passwd()
#
#  The string should be of the form type:salt:hashed-password.
