#!/bin/bash

set -m # Enable Job Control

for i in `seq 30`; do # start 30 jobs in parallel
  sleep 10 & WAITPID=$! 
done

# Wait for all parallel jobs to finish
while [ 1 ]; do fg 2> /dev/null; [ $? == 1 ] && break; done
