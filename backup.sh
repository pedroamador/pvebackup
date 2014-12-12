#!/bin/bash
currentdir=$(dirname $0)
echo "Host node server backup script (c) Pedro Amador 2011-2014"
# Determine backup period
period=''
if [ `date +%e` == 1 ]
then
  period='monthly'
elif [ `date +%u` == 7 ]
then
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
