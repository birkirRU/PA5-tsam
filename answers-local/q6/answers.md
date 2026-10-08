# Question 6 - Configure and test the firewall

## Question 6b - Firewall test
<!--
TODO: ADD TEST SECTIONS BELOW AS NEEDED

Full marks for each category below require BOTH your own documented test
here AND a matching result from the automated re-test. After documenting
your tests, run:
    a5-collect-evidence.sh Q6 <client-internal-ip>
This produces q6/evidence.txt, which independently re-tests most of the
same categories (management SSH, internal SSH/ICMP, Internet ICMP/SSH/
HTTP/HTTPS/DNS, and one blocked-port probe) and is cross-checked against
what you write below. It does not replace your own tests.
-->

## 6a first part (excluding additional policies)
--- 
### Test: SSH access to the gateway through the management interface
* Command: `ssh tsam@192.168.56.20` (from the host)
* Expected result: Password prompt and successful login, because SSH (TCP port 22) is explicitly allowed on `eth1`
* Observed result: As expected
* Command output:
```text
$ ssh tsam@192.168.56.20
tsam@192.168.56.20's password: 
Welcome to Alpine!

```


### Test: Return traffic for permitted connections
* Command: `ping -c 2 8.8.8.8` and `nslookup google.com 8.8.8.8` (on the gateway)
* Expected result: Both succeed. Outgoing traffic from the gateway is allowed (output policy accept), and the replies are accepted by the input chain only because of the `ct state established,related` rule.
* Observed result: As expected
* Command output:
```text
tsam@gateway:~$ ping -c 2 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=64 time=78.1 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=64 time=67.6 ms

--- 8.8.8.8 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1001ms
rtt min/avg/max/mdev = 67.580/72.825/78.070/5.245 ms

tsam@gateway:~$ nslookup google.com 8.8.8.8
Server:         8.8.8.8
Address:        8.8.8.8:53

Non-authoritative answer:
Name:   google.com
Address: 142.251.20.139
Name:   google.com
Address: 142.251.20.101

```


### Test: Blocked other traffic from client to Internet
* Command: `ncat -v -w 3 8.8.8.8 8080` and `ncat -v -w 3 8.8.8.8 5000` (on the client)
* Expected result: Both connection attempts time out. Only ICMP, SSH, HTTP, HTTPS and DNS are explicitly allowed from the client to the Internet, and TCP ports 8080 and 5000 are not among them, so the forward chain drops the packets silently (timeout, not "connection refused").
* Observed result: As expected
* Command output:
```text
tsam@client:~$ ncat -v -w 3 8.8.8.8 8080
Ncat: Version 7.99 ( https://nmap.org/ncat )
Ncat: TIMEOUT.

tsam@client:~$ ncat -v -w 3 8.8.8.8 5000
Ncat: Version 7.99 ( https://nmap.org/ncat )
Ncat: TIMEOUT.
```



### Test: Blocked other traffic from client to gateway
* Command: `ncat -v -w 3 10.123.123.1 80` and `ncat -v -w 3 10.123.123.1 5000` (on the client)
* Expected result: Both connection attempts time out. Only ICMP, SSH and DHCP are explicitly allowed from the internal network to the gateway, and TCP ports 80 and 5000 are not among them, so the input chain drops the packets silently (timeout, not "connection refused").
* Observed result: As expected
* Command output:
```text
tsam@client:~$ ncat -v -w 3 10.123.123.1 80
Ncat: Version 7.99 ( https://nmap.org/ncat )
Ncat: TIMEOUT.

tsam@client:~$ ncat -v -w 3 10.123.123.1 5000
Ncat: Version 7.99 ( https://nmap.org/ncat )
Ncat: TIMEOUT.
```

### Test: Blocked other traffic from host to gateway
* Command: `nmap -Pn -p 22,80,8080 192.168.56.20` and `ping -c 2 -W 2 192.168.56.20` (on the host)
* Expected result: Port 22 is open (the only service allowed on `eth1`), while ports 80 and 8080 are reported as filtered (dropped by the default input policy). The ping gets no replies, because ICMP is not allowed on `eth1`.
* Observed result: As expected
* Command output:
```text
assignment5 git:(main) nmap -Pn -p 22,80,8080 192.168.56.20
Starting Nmap 7.92 ( https://nmap.org ) at 2026-10-08 00:46 CEST
Nmap scan report for 192.168.56.20
Host is up (0.00020s latency).

PORT     STATE    SERVICE
22/tcp   open     ssh
80/tcp   filtered http
8080/tcp filtered http-proxy

Nmap done: 1 IP address (1 host up) scanned in 1.29 seconds
assignment5 git:(main) ping -c 2 -W 2 192.168.56.20
PING 192.168.56.20 (192.168.56.20) 56(84) bytes of data.

--- 192.168.56.20 ping statistics ---
2 packets transmitted, 0 received, 100% packet loss, time 1013ms

```

---

## 6a second part (additional policies)
---

### Test: SSH access to the gateway from the client and vice versa

* Command: `ssh tsam@10.123.123.1` (on the client) and `ssh tsam@10.123.123.79` (on the gateway)
* Expected result: Both connections succeed, prompted for password, logged in to the gateway and the client respectively
* Observed result: As expected
* Command output:

```text
tsam@client:~$ ssh tsam@10.123.123.1
tsam@10.123.123.1's password:
Welcome to Alpine!


tsam@gateway:~$ ssh tsam@10.123.123.79
tsam@10.123.123.79's password:
Welcome to Alpine!
```

### Test: ICMP between the client and gateway

* Command: `ping -c 3 10.123.123.1` (on the client) and `ping -c 3 10.123.123.79` (on the gateway)
* Expected result: Three replies, 0% packet loss in both directions
* Observed result: As expected
* Command output:

```text
tsam@client:~$ ping -c 3 10.123.123.1
PING 10.123.123.1 (10.123.123.1) 56(84) bytes of data.
64 bytes from 10.123.123.1: icmp_seq=1 ttl=64 time=0.806 ms
64 bytes from 10.123.123.1: icmp_seq=2 ttl=64 time=0.555 ms
64 bytes from 10.123.123.1: icmp_seq=3 ttl=64 time=0.604 ms

--- 10.123.123.1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2002ms
rtt min/avg/max/mdev = 0.555/0.655/0.806/0.108 ms


tsam@gateway:~$ ping -c 3 10.123.123.79
PING 10.123.123.79 (10.123.123.79) 56(84) bytes of data.
64 bytes from 10.123.123.79: icmp_seq=1 ttl=64 time=0.443 ms
64 bytes from 10.123.123.79: icmp_seq=2 ttl=64 time=0.244 ms
64 bytes from 10.123.123.79: icmp_seq=3 ttl=64 time=0.419 ms

--- 10.123.123.79 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2049ms
rtt min/avg/max/mdev = 0.244/0.368/0.443/0.088 ms
```

### Test: Client to external ICMP, SSH, HTTP, HTTPS and DNS

* Command: `ping -c 3 8.8.8.8`, `ssh -T git@github.com`, `wget http://example.com`, `wget https://example.com` and `nslookup google.com` (all on the client)
* Expected result: The ping gets three replies with 0% packet loss. GitHub's server answers the SSH connection with "Permission denied (publickey)", showing that port 22 traffic passes the firewall. Both wget commands connect and finish the download without errors. The DNS lookup succeeds via 8.8.8.8 and returns addresses for google.com.
* Observed result: As expected
* Command output:

```text
tsam@client:~$ ping -c 3 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=62 time=68.0 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=62 time=101 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=62 time=18.1 ms

--- 8.8.8.8 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2002ms
rtt min/avg/max/mdev = 18.118/62.433/101.195/34.142 ms

tsam@client:~$ ssh -T git@github.com
git@github.com: Permission denied (publickey).

tsam@client:~$ wget http://example.com
Connecting to example.com (104.20.23.154:80)
saving to 'index.html'
index.html           100% |************************************************************|   577  0:00:00 ETA
'index.html' saved

tsam@client:~$ wget https://example.com
Connecting to example.com (104.20.23.154:443)
saving to 'index.html'
index.html           100% |************************************************************|   577  0:00:00 ETA
'index.html' saved

tsam@client:~$ nslookup google.com
Server:         8.8.8.8
Address:        8.8.8.8:53

Non-authoritative answer:
Name:   google.com
Address: 142.250.154.101
...
...
```


---