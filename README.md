Linux创建临时IPv6隧道
```
ip tunnel add ipv6 mode sit remote 72.52.104.74 local 172.17.0.2 ttl 64
ip link set ipv6 up
ip addr add 2001:470:1f04:2b8::2/64 dev ipv6
ip route add default via 2001:470:1f04:2b8::1 dev ipv6
```
