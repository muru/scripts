#! /bin/sh
iptables -A OUTPUT -m owner --gid-owner netblock -j REJECT
