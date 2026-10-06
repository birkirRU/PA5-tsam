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
* Command: ssh tsam@192.168.56.20
* Expected result: Password prompt/login
* Observed result: as expected (`eth1` on port 22)
* Command output:
```text
$ ssh tsam@192.168.56.20
tsam@192.168.56.20's password: 
Welcome to Alpine!
```


### Test: Return traffic for permitted connections

* Command: `ping -c 2 8.8.8.8`, `nslookup google.com 8.8.8.8` and `wget -O /dev/null http://example.com` (on the gateway)
* Expected result: All succeed. The gateway's outgoing traffic is allowed (output policy accept), and the replies are accepted by the input chain only because of the `ct state established,related` rule, since there is no other rule that allows incoming ICMP, DNS or TCP replies.
* Observed result: [WRITE WHAT HAPPENED]
* Command output:

```text
$ ping -c 2 8.8.8.8
PING 8.8.8.8 (8.8.8.8): 56 data bytes
64 bytes from 8.8.8.8: seq=0 ttl=255 time=...ms
64 bytes from 8.8.8.8: seq=1 ttl=255 time=...ms

--- 8.8.8.8 ping statistics ---
2 packets transmitted, 2 packets received, 0% packet loss

$ nslookup google.com 8.8.8.8
Server:		8.8.8.8
Address:	8.8.8.8:53

Non-authoritative answer:
Name:	google.com
Address: 142.250.x.x

$ wget -O /dev/null http://example.com
Connecting to example.com (...)
...
'/dev/null' saved
```


### Test: Blocked other traffic from client to Internet

* Command: `ping -c 2 -W 2 8.8.8.8`, `nslookup google.com 8.8.8.8` and `wget -T 3 -O /dev/null http://8.8.8.8` (on the client)
* Expected result: All fail or time out. The forward chain has policy drop and no rules allowing client traffic yet, so the packets are dropped silently (timeout, not "connection refused").
* Observed result: [WRITE WHAT HAPPENED]
* Command output:

```text
$ ping -c 2 -W 2 8.8.8.8
PING 8.8.8.8 (8.8.8.8): 56 data bytes

--- 8.8.8.8 ping statistics ---
2 packets transmitted, 0 packets received, 100% packet loss

$ nslookup google.com 8.8.8.8
;; connection timed out; no servers could be reached

$ wget -T 3 -O /dev/null http://8.8.8.8
Connecting to 8.8.8.8 (8.8.8.8:80)
wget: download timed out
```



### Test: Blocked other traffic from client to gateway

* Command: `ping -c 2 -W 2 10.123.123.1` and `ssh -o ConnectTimeout=3 tsam@10.123.123.1` (on the client)
* Expected result: Both fail or time out. The input chain only accepts established/related traffic, loopback and SSH on eth1. Nothing is allowed on eth2 yet, so these packets are dropped.
* Observed result: [WRITE WHAT HAPPENED]
* Command output:

```text
$ ping -c 2 -W 2 10.123.123.1
PING 10.123.123.1 (10.123.123.1): 56 data bytes

--- 10.123.123.1 ping statistics ---
2 packets transmitted, 0 packets received, 100% packet loss

$ ssh -o ConnectTimeout=3 tsam@10.123.123.1
ssh: connect to host 10.123.123.1 port 22: Connection timed out
```


### Test: Blocked other traffic from host to gateway

* Command: `nmap -Pn -p 22,80,8080 192.168.56.20` and `ping -c 2 -W 2 192.168.56.20` (on the host)
* Expected result: Port 22 is open (the eth1 SSH rule), while ports 80 and 8080 show as filtered (dropped by the default input policy). The ping gets no replies, because ICMP isn't allowed on eth1.
* Observed result: [WRITE WHAT HAPPENED]
* Command output:

```text
$ nmap -Pn -p 22,80,8080 192.168.56.20
PORT     STATE    SERVICE
22/tcp   open     ssh
80/tcp   filtered http
8080/tcp filtered http-proxy

$ ping -c 2 -W 2 192.168.56.20
PING 192.168.56.20 (192.168.56.20) 56(84) bytes of data.

--- 192.168.56.20 ping statistics ---
2 packets transmitted, 0 received, 100% packet loss
```

---

## 6a second part (additional policies)
---

TODO test
- SSH access to the gateway from the client and vice versa;
- ICMP between the client and gateway;
- Client to external ICMP, SSH, HTTP, HTTPS, DNS

### Test: 
* Command: 
* Expected result: 
* Observed result:
* Command output:
```text
output
```


---