# Question 4 - Observe a packet through NAT

## Question 4a - Packet table

| Packet | Source MAC        | Destination MAC   | Source IP    | Destination IP | TTL | ICMP type |
| ------ | ----------------- | ----------------- | ------------ | -------------- | --- | --------- |
| 1      | 08:00:27:fe:47:f0 | 08:00:27:4b:26:fb | 10.123.123.2 | 8.8.8.8        | 64  | 8         |
| 2      | 08:00:27:e4:47:dd | 52:54:00:12:35:00 | 10.0.2.15    | 8.8.8.8        | 63  | 8         |
| 3      | 52:54:00:12:35:00 | 08:00:27:e4:47:dd | 8.8.8.8      | 10.0.2.15      | 63  | 0         |
| 4      | 08:00:27:4b:26:fb | 08:00:27:fe:47:f0 | 8.8.8.8      | 10.123.123.2   | 62  | 0         |

## Question 4b - Source and Destination Interfaces

| Packet | Source interface      | Destination interface |
| ------ | --------------------- | --------------------- |
| 1      | eth0 on client        | eth2 on gateway       |
| 2      | eth0 on gateway       | VirtualBox NAT router |
| 3      | VirtualBox NAT router | eth0 on gateway       |
| 4      | eth2 on gateway       | eth0 on client        |

## Question 4c
### Why do both the source and destination Ethernet addresses change between packet 1 and 2, despite the destination IP address being the same?
The destination IP identifies the final recipient and is kept end to end, while the MAC addresses identify only the next hop on each link. The client resolves the MAC of its next hop (the gateway) from the routing table via ARP, and the gateway does the same for its own next hop.

The main reason why MAC is different, while IP is not, is because MAC solves the case of what exact recipient should get the frame in the data link layer (identification of next interface per hop), while IP (in Network layer) abstracts this by holding onto the final recipient for the duration of the trip.
## Question 4d
### How does the gateway associate the reply with the original request?

The gateway uses the ICMP identifier. This means that when the request goes through NAT, an entry is stored in the NAT table which contains the ICMP identifier. The gateway now has an entry linking the client's internal address and the ICMP identifier to its own external address. The reply then carries this same ICMP identifier as the request because it was copied back by the receiver. When the reply finally arrives, the gateway simply has to look up the ICMP identifier in the NAT table and then change the destination address to the address linked to the identifier.
