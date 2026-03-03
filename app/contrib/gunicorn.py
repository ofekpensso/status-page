# The IP address (typically localhost) and port that the Status-Page WSGI process should listen on
bind = '127.0.0.1:8001'

# Number of gunicorn workers to spawn. This should typically be 2n+1, where
# n is the number of CPU cores present.
workers = 5

# Number of threads per worker process
threads = 3

# Timeout (in seconds) for a request to complete
timeout = 120

# The maximum number of requests a worker can handle before being respawned
max_requests = 5000
max_requests_jitter = 500

# Logging — stream everything to stdout (12-factor style, no local files)
accesslog = '-'
errorlog = '-'
loglevel = 'info'
access_log_format = '%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s"'
