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
  echo "        backup daily [ctid] [ctid] ... - for daily backup"
  echo "        backup weekly [ctid] [ctid] ... - for weekly backup"
  echo "        backup monthly [ctid] [ctid] ... - for monthly backup"
  echo ""
  echo " The [ctid] ... is a list of ID's to exclude in the backup"
  exit 1
fi

echo `date +"%Y-%m-%d %X"`": backing up $period period "

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
tar -czf /var/backups/localhost/$period/_root_`date +%Y%m%d`.tar.gz /root /etc 2> /dev/null
if [[ $period == 'weekly' || $period == 'monthly' ]]
then
  maxfiles=1
else
  maxfiles=2
fi
ionice -c3 /usr/bin/vzdump -compress 1 -mode snapshot -storage $period -stdexcludes -maxfiles $maxfiles -all $exclude
