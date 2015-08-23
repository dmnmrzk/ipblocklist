#!/usr/bin/env bash

BLOCKLISTS=(
    #IP-Blocklist Pedophiles
    'http://192.99.169.206/f/bcaavqbidvoscxmvmaax/dufcxgnbjsdwmwctgfuj.gz'
    #Bluetack lvl1
    'http://192.99.169.206/f/zrcieulibzdirluxehfm/ydxerpxkpcfqjaybcssw.gz'
    #Bluetack lvl2
    'http://167.114.152.62/f/eosqazdlokjpnhuvnrzj/gyisgnzbhppbvsphucsw.gz'
    #IP-Blocklist Poland
    'http://192.99.169.127/f/xoyjndbaszapnczxmsvp/pl.gz'
    #IPdeny list for Poland
    'http://www.ipdeny.com/ipblocks/data/countries/pl.zone'
    )

if [ "$EUID" -ne 0 ] ; then echo "Please run as root." ; exit 1 ; fi
command -v ipset >/dev/null 2>&1 || { echo >&2 "Ipset it's not installed.  Aborting."; exit 1; }

ipset list ipblocklist >/dev/null 2>/dev/null
if [ $? -ne 0 ] ; then ipset create ipblocklist hash:net maxelem 500000 ; fi

for list in ${BLOCKLISTS[*]}; do
    if [[ $(curl -sS -I $list | grep "Content-Type") =~ "gzip" ]]; then 
        wget -q -O- $list | gzip -dc | egrep -v '\#|^$|127\.0\.0' | sed 's:^:add\ \-exist\ ipblocklist\ :g' | ipset restore
    else
        wget -q -O- $list | egrep -v '\#|^$|127\.0\.0' | sed 's:^:add\ \-exist\ ipblocklist\ :g' | ipset restore
    fi
done

