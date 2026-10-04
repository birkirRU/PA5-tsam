# Question 4 - Observe a packet through NAT

## Question 4a - Packet table
| Packet | Source MAC        | Destination MAC   | Source IP    | Destination IP | TTL | ICMP type |
| ------ | ----------------- | ----------------- | ------------ | -------------- | --- | --------- |
| 1      | 08:00:27:e4:47:dd | 52:54:00:12:35:00 | 10.0.2.15    | 8.8.8.8        | 63  | 8         |
| 2      | 08:00:27:fe:47:f0 | 08:00:27:4b:26:fb | 10.123.123.2 | 8.8.8.8        | 64  | 8         |
| 3      | 52:54:00:12:35:00 | 08:00:27:e4:47:dd | 8.8.8.8      | 10.0.2.15      | 63  | 0         |
| 4      | 08:00:27:4b:26:fb | 08:00:27:fe:47:f0 | 8.8.8.8      | 10.123.123.2   | 62  | 0         |
TODO: FLIP 1 and 2. i accidently flipped it, 2 is supposed to be ahead of 1.

## Question 4b - Source and Destination Interfaces

The answers below are based of if the TODO above is being followed.

| Packet | Source interface | Destination interface |
| ------ | ---------------- | --------------------- |
| 1      | eth0 on client   | eth2 on gateway       |
| 2      | eth0 on gateway  | ??                    |
| 3      | ??               | eth0 on gateway       |
| 4      | eth2 on gateway  | eth0 on client        |

## Question 4c
### Why do both the source and destination Ethernet addresses change between packet 1 and 2, despite the destination IP address being the same?

[WRITE YOUR ANSWER HERE]

## Question 4d
### How does the gateway associate the reply with the original request?

[WRITE YOUR ANSWER HERE]
