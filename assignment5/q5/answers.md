# Question 5 - Configure DHCP

<!--
Question 5a (dnsmasq.conf) is graded from q5/dnsmasq.conf directly; there is
nothing to fill in here for that part.

Question 5b (client /etc/network/interfaces) is collected automatically by
a5-collect-evidence.sh Q5 <client-internal-ip> into q5/evidence.txt.
You do not need to copy the configuration file here by hand.
-->

## Question 5c
### Check whether the client received the right configuration from DHCP
<!--
Describe how you checked (which commands you ran) and what you found.
-->
```text

tsam@client:~$ ip addr show dev eth0
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:fe:47:f0 brd ff:ff:ff:ff:ff:ff
    inet 10.123.123.79/24 brd 10.123.123.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fefe:47f0/64 scope link proto kernel_ll 
       valid_lft forever preferred_lft forever


tsam@client:~$ ip route show default
default via 10.123.123.1 dev eth0 metric 202 


tsam@client:~$ cat /etc/resolv.conf
nameserver 8.8.8.8


tsam@client:~$ ping -c 2 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=62 time=68.2 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=62 time=94.2 ms

--- 8.8.8.8 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1000ms
rtt min/avg/max/mdev = 68.212/81.194/94.176/12.982 ms

tsam@client:~$ nslookup google.com | head -n 5
Server:         8.8.8.8
Address:        8.8.8.8:53

Name:   google.com
Address: 142.250.154.102
```
