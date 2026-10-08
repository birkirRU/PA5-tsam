# Question 3 - Routing, forwarding, and NAT

## Question 3a - Client route
### Commands used
```text
tsam@client:~$ sudo ip route add default via 10.123.123.1 dev eth0


tsam@client:~$ ip route
default via 10.123.123.1 dev eth0
10.123.123.0/24 dev eth0 proto kernel scope link src 10.123.123.2 
192.168.56.0/24 dev eth1 proto kernel scope link src 192.168.56.21 

```

## Question 3b - Enable IPv4 forwarding
### Commands used
```text
tsam@gateway:~$ sudo sysctl -w net.ipv4.ip_forward=1
net.ipv4.ip_forward = 1

tsam@gateway:~$ sysctl net.ipv4.ip_forward
net.ipv4.ip_forward = 1

tsam@gateway:~$ sudo cat /etc/sysctl.conf
net.ipv4.ip_forward = 1
```

## Question 3d - Test Internet connectivity
### Which command works as expected and which does not? Why?

`ping` works as expected, but `nslookup` does not. 
The reason why `nslookup` refused connection is because the client has no database server to ask for the IP of `google.com`. This can be clearly seen when looking into `/etc/resolv.conf` which should store DNS lookup servers; it is empty. Usually, a DHCP header stores the DNS server IP's inside `option` section, but since we manually setup the private IP of the client within LAN; no DNS IP is configured for our client.
Basically, up until now, we have only configured the router (tsam@gateway) to forward packets coming from client to the internet. An IP is the bare minimum needed for the end server in order to send a packet, but `google.com` isn't an IP, and needs a lookup; but client cannot look up because it doesn't know the database server that knows the IP mapping.
### Commands used

#### Client
```text
tsam@client:~$ ping -c 3 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=62 time=459 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=62 time=134 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=62 time=93.8 ms

--- 8.8.8.8 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2001ms
rtt min/avg/max/mdev = 93.798/229.258/459.498/163.648 ms

tsam@client:~$ nslookup google.com
nslookup: write to '127.0.0.1': Connection refused
;; connection timed out; no servers could be reached

tsam@client:~$ cat /etc/resolv.conf

```

#### Gateway
```text
tsam@gateway:~$ cat /etc/resolv.conf
search wist-salzburg.com
nameserver 1.1.1.1
nameserver 9.9.9.9
nameserver 8.8.8.8
```

<!--
After completing this question, run:
    a5-collect-evidence.sh Q3 10.123.123.2
-->
