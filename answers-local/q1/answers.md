# Question 1 - Initial network inspection

## Question 1a: gateway interfaces
<!--
Replace the table contents and append complete command output below it.
Do not remove the table headings.
Do not leave the example entries in the table!
Link state is either up, down or unknown
-->

Interface | Link state | IP address/subnet | Static/dynamic |
----------|------------|-------------------|----------------|
lo        | unknown    | 127.0.0.1/8       | static         |
eth0      | up         | 10.0.2.15/24      | static.        |
eth1      | up         | 192.168.56.20/24  | static         |
eth2      | down       | NOT SET           | NOT SET        |

Route to           | via             | Interface |
-------------------|-----------------|-----------|
default            | 10.0.2.2        | eth0      |
10.0.2.0/24        | None (MAC)      | eth0      |
192.168.56.0/24    | None (MAC)      | eth1      |

### COMMAND LOG
```text
tsam@gateway:~$ ip link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
    link/ether 08:00:27:e4:47:dd brd ff:ff:ff:ff:ff:ff
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
    link/ether 08:00:27:41:f2:84 brd ff:ff:ff:ff:ff:ff
4: eth2: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 08:00:27:4b:26:fb brd ff:ff:ff:ff:ff:ff


tsam@gateway:~$ ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host proto kernel_lo 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:e4:47:dd brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fd17:625c:f037:2:a00:27ff:fee4:47dd/64 scope global dynamic mngtmpaddr proto kernel_ra 
       valid_lft 86121sec preferred_lft 14121sec
    inet6 fe80::a00:27ff:fee4:47dd/64 scope link proto kernel_ll 
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:41:f2:84 brd ff:ff:ff:ff:ff:ff
    inet 192.168.56.20/24 scope global eth1
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe41:f284/64 scope link proto kernel_ll 
       valid_lft forever preferred_lft forever
4: eth2: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether 08:00:27:4b:26:fb brd ff:ff:ff:ff:ff:ff


tsam@gateway:~$ ip route
default via 10.0.2.2 dev eth0 metric 202 
10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15 
192.168.56.0/24 dev eth1 proto kernel scope link src 192.168.56.20 

```

## Question 1b: client interfaces
<!--
Replace the table contents and append complete command output below it.
Do not remove the table headings.
Do not leave the example entries in the table!
Link state is either up, down or unknown
-->

Interface | Link state | IP address/subnet | Static/dynamic |
----------|------------|-------------------|----------------|
lo        | unknown    | 127.0.0.1/8       | static         |
eth0      | down       | NOT SET           | NOT SET        |
eth1      | up         | 192.168.56.21/24  | static         |

Route to           | via             | Interface |
-------------------|-----------------|-----------|
192.168.56.0/24    | none (MAC)      | eth1      |

### COMMAND LOG
```text
tsam@client:~$ ip link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 08:00:27:fe:47:f0 brd ff:ff:ff:ff:ff:ff
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
    link/ether 08:00:27:ac:04:b3 brd ff:ff:ff:ff:ff:ff


tsam@client:~$ ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host proto kernel_lo 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether 08:00:27:fe:47:f0 brd ff:ff:ff:ff:ff:ff
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:ac:04:b3 brd ff:ff:ff:ff:ff:ff
    inet 192.168.56.21/24 scope global eth1
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:feac:4b3/64 scope link proto kernel_ll 
       valid_lft forever preferred_lft forever


tsam@client:~$ ip route
192.168.56.0/24 dev eth1 proto kernel scope link src 192.168.56.21 

```

## Question 1c - Why does ping and nslookup not work on the client?

The reason why the client cannot ping nor perform network DNS lookups, is because it doesn't have a default gateway out to the internet, it is yet to be configured. This can be seen in the output of the `ip route` of `1b`, no "default" keyword is displayed in the first line of output. The default gateway IP is the router's IP within the LAN (which client is connected to). It forwards your request to the internet. 

To the contrary, the gateway VM, has default gateway, hence allows routing.

#### Client

```client
tsam@client:~$ ping 8.8.8.8
ping: connect: Network unreachable
tsam@client:~$ nslookup google.com
nslookup: write to '127.0.0.1': Connection refused
;; connection timed out; no servers could be reached
```

---
#### Gateway

```
tsam@gateway:~$ nslookup google.com
Server:         1.1.1.1
Address:        1.1.1.1:53
...
...

tsam@gateway:~$ ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=64 time=29.8 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=64 time=55.0 ms
c^C
--- 8.8.8.8 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1002ms
rtt min/avg/max/mdev = 29.788/42.400/55.012/12.612 ms
```