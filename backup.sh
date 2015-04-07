#!/bin/bash
currentdir=$(dirname $0)
echo "Host node server backup script (c) Pedro Amador 2011-2014"
# Determine backup period
period=''
if [ `date +%e` -le 7 ] && [ `date +%u` == 1 ]
then
  # Monthly; first sunday of month (monthday <= 7, weekday = 1)
  period='monthly'
elif [ `date +%u` == 7 ]
then
  # Weekly: all sundays
  period='weekly'
else
  period='daily'
fi
# Get exclude list
exclude=`head -n1 $currentdir/$period.exclude 2> /dev/null`

# Exec backup script
$currentdir/_backup_period.sh $period $exclude

# Do other things
$currentdir/post_script.sh $period
