Linux创建临时IPv6隧道
```
ip tunnel add ipv6 mode sit remote 66.220.18.42 local 172.17.0.2 ttl 64
ip link set ipv6 up
ip addr add 2001:470:c:1074::2/64 dev ipv6
ip route add default via 2001:470:c:1074::1 dev ipv6
```
