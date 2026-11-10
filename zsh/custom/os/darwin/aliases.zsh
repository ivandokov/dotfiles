# -G asks BSD ls for colour.
alias l='ls -lFhG'
alias ll='ls -laFhG'

alias dnsclear='dscacheutil -flushcache; sudo killall -HUP mDNSResponder'

alias backup-photos='rsync -arv $HOME/Pictures/Phockup/ /Volumes/3TB/Photos'

alias btrestart='blueutil -p 0 && sleep 1 && blueutil -p 1'

# `ip` is a core utility on Linux, so the shared function is called myip and
# the short name is only claimed here, where nothing else uses it.
alias ip='myip'
