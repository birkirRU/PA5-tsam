# Question 2 — Configure the internal network

## Question 2a
### Gateway configuration
```text
$ sudo ip addr add 10.123.123.1/24 dev eth2
$ sudo ip link set eth2 up
```

### Client configuration
```text
$ sudo ip addr add 10.123.123.2/24 dev eth0
$ sudo ip link set eth0 up
```

## Question 2b
<!--
Full marks require BOTH a passing automated test (from
a5-collect-evidence.sh Q2 <client-internal-ip>, run after this question)
AND a documented test of your own below. Documenting your own test is
required even if the automated evidence also succeeds.
-->
### Testing connectivity Gateway -> Client

```text
$ ping 10.123.123.2
PING 10.123.123.2 (10.123.123.2) 56(84) bytes of data.
64 bytes from 10.123.123.2: icmp_seq=1 ttl=64 time=0.846 ms
64 bytes from 10.123.123.2: icmp_seq=2 ttl=64 time=0.313 ms
64 bytes from 10.123.123.2: icmp_seq=3 ttl=64 time=0.489 ms
^C
```

### Testing connectivity Client -> Gateway

```text
$ ping 10.123.123.1
PING 10.123.123.1 (10.123.123.1) 56(84) bytes of data.
64 bytes from 10.123.123.1: icmp_seq=1 ttl=64 time=0.569 ms
64 bytes from 10.123.123.1: icmp_seq=2 ttl=64 time=0.377 ms
^C
```

## Question 2c
### Why does the client not have Internet connectivity?

The client has no default gateway (default route) configured. Its routing table only contains the directly connected networks (10.123.123.0/24 and 192.168.56.0/24), so it has no route for destinations outside them, such as 8.8.8.8, and the ping fails with "Network unreachable".

```text
$ ip route
10.123.123.0/24 dev eth0 proto kernel scope link src 10.123.123.2 
192.168.56.0/24 dev eth1 proto kernel scope link src 192.168.56.21 

$ ping 8.8.8.8
ping: connect: Network unreachable
```

<!--
After completing this question, run:
    a5-collect-evidence.sh Q2 10.123.123.2
-->