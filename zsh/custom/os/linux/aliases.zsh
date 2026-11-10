alias l='ls -lFh --color=auto'
alias ll='ls -laFh --color=auto'

alias dnsclear='sudo resolvectl flush-caches 2>/dev/null || sudo systemctl restart systemd-resolved'

alias btrestart='bluetoothctl power off && sleep 1 && bluetoothctl power on'

