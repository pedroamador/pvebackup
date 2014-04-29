#!/bin/bash
echo "Host node server backup script (c) Pedro Amador 2011-2014"
# Determine backup period
period=''
if [ `date +%e` == 1 ]
then
  period='monthly'
elif [ `date +%u` == 0 ]
then
  period='weekly'
else
  period='daily'
fi
# Get exclude list
exclude=`head -n1 /root/cron/$period.exclude`

# Exec backup script
/opt/backup/backup_period.sh $period $exclude

# Do other things
/opt/backup/post_script.sh
