# Aliases for ts Task Spooler
# http://vicerveza.homeunix.net/~viric/soft/ts/
# Define three queues for CPU, Disk I/O and Network
# cpuq, ioq, netq

alias cpuq='TS_SOCKET=/tmp/ts_cpuq tsp'
alias netq='TS_SOCKET=/tmp/ts_netq tsp'
alias ioq='TS_SOCKET=/tmp/ts_ioq tsp'
