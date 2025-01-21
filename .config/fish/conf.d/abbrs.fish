#!/usr/bin/env fish

set -q MY_ABBRS_INITIALIZED; and return

abbr -a -- _ sudo
abbr -a -- c clear

# grep
abbr -a -- sgrep 'grep -R -n -H -C 5'

# less
abbr -a -- less 'less -FSRXc'

# process management
abbr -a -- memprocs 'ps wwaxm -o pid,stat,vsize,rss,time,command | head -10'
abbr -a -- cpuprocs 'ps wwaxr -o pid,stat,%cpu,time,command | head -10'

# chmod
abbr -a -- perm 'stat --printf "%a %n \n "' # Show permission of target in number
abbr -a -- 000 'chmod 000'                  # ---------- (nobody)
abbr -a -- 640 'chmod 640'                  # -rw-r----- (user: rw, group: r)
abbr -a -- 644 'chmod 644'                  # -rw-r--r-- (user: rw, group: r, other: r)
abbr -a -- 755 'chmod 755'                  # -rwxr-xr-x (user: rwx, group: rx, other: rx)
abbr -a -- 775 'chmod 775'                  # -rwxrwxr-x (user: rwx, group: rwx, other: rx)
abbr -a -- mx 'chmod a+x'                   # ---x--x--x (user: --x, group: --x, other: --x)
abbr -a -- ux 'chmod u+x'                   # ---x------ (user: --x, group: -, other: -)

# disk usage
abbr -a -- dud 'du -d 1 -h' # Short and human-readable directory listing
abbr -a -- duf 'du -sh *'   # Short and human-readable file listing

# rsync
abbr -a -- rcopy "rsync -avz --progress -h"
abbr -a -- rmove "rsync -avz --progress -h --remove-source-files"
abbr -a -- rupdate "rsync -avzu --progress -h"
abbr -a -- rsynch "rsync -avzu --delete --progress -h"

# no need to run over-and-over
set -g MY_ABBRS_INITIALIZED true
