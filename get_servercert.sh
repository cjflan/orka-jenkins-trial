#!/bin/bash

script -c "echo no | openconnect 199.7.162.42" log.log 
grep 'pin-sha256:' log.log | sed 's/.*://' >> servercert.txt