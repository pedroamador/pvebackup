#!/bin/bash
period=''
# Check argument
if [[ $# -eq 0 ]]
then
  period='error'
  msg="You must specify daily, weekly or monthly period"
else
  # Check argument is daily / weekly / monthly
  if [[ $1 == 'daily' || $1 == 'weekly' || $1 == 'monthly' ]]
  then
    period=$1
  else
    period='error'
    msg="Incorrect argument: $1"
  fi
fi
# Error check
if [[ $period == 'error' ]]  
then
  echo ""
  echo "Error: $msg"
  echo "Use:"
  echo "        backup daily [snapshot] [ctid] [ctid] ... - for daily backup"
  echo "        backup weekly [snapshot] [ctid] [ctid] ... - for weekly backup"
  echo "        backup monthly [snapshot] [ctid] [ctid] ... - for monthly backup"
  echo ""
  echo " With [snapshot] the script uses 'snapshot' option of vzdump"
  echo " - Six 'daily' snapshots (one complete week)"
  echo " - Two 'weekly' snapshots (all sundays of month), with one vzdump of all CT's and VM's except exclude list, from last saturnday"
  echo " - One 'monthly' (one month), with one vzdump of all CT's and VM's except exclude list, from last 'first monday' of the month"
  echo " Use snapshots only with ZFS storage"
  echo ""
  echo " The [ctid] ... is a list of ID's to exclude in the backup"
  exit 1
fi

echo `date +"%Y-%m-%d %X"`": backing up $period period "

# Get snapshot
if [[ $2 == 'snapshot' ]]
then
  snapshot=true
  shift
else
  snapshot=false
fi

# Make exclude list
shift
exclude=""
while [[ $# -ne 0 ]]
do
  exclude="$exclude -exclude $1"
  shift
done
echo "Excluding $exclude"

# Do backup
tar -czf /var/backups/localhost/$period/pvebackup_config_`hostname -s`_`date +%A`.tar.gz /root /etc 2> /dev/null
if [[ $period == 'weekly' || $period == 'monthly' ]]
then
  maxfiles=1
  if [[ $period == 'weekly' ]]
  then
    snapshotname="weekly_$((($(date +%-d)-1)/7+1))_pvebackup"
  else
    snapshotname="monthly_pvebackup"
  fi
else
  maxfiles=2
  snapshotname="daily_`date +%u`_pvebackup"
fi
if [[ $snapshot == true ]]
then
  vmlist=$(qm list | grep -v VMID | awk '{print $1}')
  ctlist=$(pct list | grep -v VMID | awk '{print $1}')
  for vm in $vmlist
  do
    echo "pvebakup: take $snapshotname snapshot on $vm virtual machine"
    qm listsnapshot $vm | grep $snapshotname -q && (qm delsnapshot $vm $snapshotname && exit $?)
    qm snapshot $vm $snapshotname -vmstate false || exit $?
  done
  for ct in $ctlist
  do
    echo "pvebakup: take $snapshotname snapshot on $ct container"
    pct listsnapshot $ct | grep $snapshotname -q && (pct delsnapshot $ct $snapshotname && exit $?)
    pct snapshot $ct $snapshotname || exit $?
  done
fi
ionice -c3 /usr/bin/vzdump -compress 1 -mode snapshot -storage $period -stdexcludes 0 -maxfiles $maxfiles -all $exclude -exclude-path '/var/backups/localhost/.+'
exit $?
