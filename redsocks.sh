iptables -t nat -N REDSOCKS
iptables -t nat -A REDSOCKS -d 0.0.0.0/8 -j RETURN
iptables -t nat -A REDSOCKS -d 10.0.0.0/8 -j RETURN
iptables -t nat -A REDSOCKS -d 127.0.0.1/8 -j RETURN
iptables -t nat -A REDSOCKS -d 192.168.0.0/16 -j RETURN
iptables -t nat -A OUTPUT -p tcp -m owner --gid-owner socksified -j REDSOCKS
iptables -t nat -A REDSOCKS -p tcp -j REDIRECT --to-ports 9052
iptables -t nat -A REDSOCKS -p udp -j REDIRECT --to-ports 9053
iptables -t nat -A REDSOCKS -p tcp --dport 80 -j REDIRECT --to-ports 9052
iptables -t nat -A REDSOCKS -p tcp --dport 443 -j REDIRECT --to-ports 9052
