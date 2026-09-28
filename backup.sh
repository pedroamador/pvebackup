#!/bin/bash
set -eu

if [[ $1 == 'snapshot' ]]
then
  snapshot="snapshot"
else
  snapshot=""
fi
currentdir=$(dirname $0)
echo "Host node server backup script (c) Pedro Amador 2011-2026"
# Determine backup period
period=''
if [ `date +%e` -le 7 ] && [ `date +%u` == 6 ]
then
  # Monthly; first saturnday of month (monthday <= 6, weekday = 6)
  period='monthly'
elif [ `date +%u` == 6 ]
then
  # Weekly: all saturnday
  period='weekly'
else
  period='daily'
fi
# Get exclude list
exclude=`head -n1 $currentdir/$period.exclude 2> /dev/null`

# Check scripts
[[ -x "$currentdir/pre_script.sh" ]] || { echo "Missing pre_script.sh, aborting"; exit 1; }
[[ -x "$currentdir/post_script.sh" ]] || { echo "Missing post_script.sh, aborting"; exit 1; }

# Pre hook
$currentdir/pre_script.sh $period $snapshot $exclude

# Exec backup script
$currentdir/_backup_period.sh $period $snapshot $exclude

# Post hook
$currentdir/post_script.sh $period $snapshot $exclude
