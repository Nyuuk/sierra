#!/bin/bash
_ping='/tmp/ping.txt'
ping 104.17.2.81 -c 3 > $_ping
if (( "$(cat $_ping|grep ms|awk NR==$(cat $_ping|grep ms|wc -l)|cut -d '/' -f 4|cut -d '.' -f 1)" > 1000 )); then
echo lebih besar
/root/sierra/sierra.sh res
else
echo lebih kecil
fi
