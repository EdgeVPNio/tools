#!/bin/bash

pingresult=/var/log/evio/ping-result.log
pingstat=/var/log/evio/ping-stat.log
pingfails=/var/log/evio/ping-failures.log
timestamp=$(date +"%D %T %Z %z")
 
function icmp_test
{
  ping -c1 $2 > /dev/null
  #iperf -c $1 -e -yC -n3G | tee -a /var/log/evio/$1-iperf-results.log
  echo -e "\n############## $HOSTNAME-->>$1 - $timestamp ##############\n" 2>&1 | tee -a $pingresult
  ping -c25 -n $2 | xargs -n1 -i bash -c 'echo `date +"%Y-%m-%d %H:%M:%S"`" {}"' 2>&1 | tee -a $pingresult
  echo -e "\n############## $HOSTNAME-->>$1 - $timestamp ##############\n" 2>&1 | tee -a $pingstat
  tail -n 2 $pingresult 2>&1 | tee -a $pingstat 
}

function ping_hosts
{
  while read ips
  do
    icmp_test $ips
    if [ "$?" -ne "0" ]; then
      echo "$(date +"%D %T %Z %z"): ICMP Failure to host $ips" | tee -a $pingfails
    fi
  done < $1
}

function run_all_tests
{
    ping_hosts $1
}

case $1 in
  run_all)
    run_all_tests $2
    ;;
  ph)
    ping_hosts $2
    ;;
  icmp)
    icmp_test $2 $3
    ;;
  *)
    echo "no match on input -> $1"
    ;;
esac

