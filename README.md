# Proxmox backup script

Simple shell script to backup proxmox host and, eventually, rsync content to other proxmox host
You can create new container or kvm and forgot to backup it. The backup script will do it for you

1. Get the code into /opt/pvebackup

    $ git clone https://github.com/pedroamador/pvebackup.git /opt/pvebackup

2. Create folders "daily", "weekly" and "monthly" in /var/backups/localhost. It's better to create new storages in your proxmox

3. Create these files files

* /opt/pvebackup/exclude.daily
* /opt/pvebackup/exclude.weekly
* /opt/pvebackup/exclude.monthly

The files will contains a list of CTID's you want to exclude from the backups, like "10002 10003 10004 ..."

4. Create the script /opt/pvebackup/post_script.sh and allow to exec it

    $ echo '#!/bin/bash' > /opt/pvebackup/post_script.sh
    $ chmod +x /opt/pvebackup/post_script.sh

5. Create /etc/cron.d/pvebackup file with these content content

    30 03	* * *	root	/opt/pvebackup/backup.sh >> /var/log/pvebackup.log 2>> /var/log/pvebackup.err

You decide the task hour and adjust to your needs

6. Done!

The /opt/pvebackup/post_script.sh should contain rsync the backups to another node

    $ cat /opt/pvebackup/post_script.sh
    #!/bin/bash
    
    # Daily copy to other host
    ionice -c3 rsync --bwlimit 25000 -av --delete /var/pvebackups/localhost/ other_proxmox_node.tld:/var/backups/$(hostname)/
