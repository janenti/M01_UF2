#/bin/bash

iptables -F

iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

iptables -t filter -A INPUT -s 10.65.0.21/24 -j ACCEPT
iptables -t filter -A OUTPUT -d 10.65.0.21/24 -j ACCEPT

iptables -t filter -A INPUT -s 10.65.0.56/24 -j ACCEPT
iptables -t filter -A INPUT -s 10.65.0.56/24 -j ACCEPT

