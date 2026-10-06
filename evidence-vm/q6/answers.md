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

### Test: SSH access to the gateway through the management interface
* Command: ssh tsam@192.168.56.20
* Expected result: Password prompt/login
* Observed result: as expected
* Command output:
```text
$ ssh tsam@192.168.56.20
tsam@192.168.56.20's password: 
Welcome to Alpine!
```

### Test: 
* Command: 
* Expected result: 
* Observed result:
* Command output:
```text
output
```
