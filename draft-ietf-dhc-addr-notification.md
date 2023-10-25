---
title: "Registering Self-generated IPv6 Addresses using DHCPv6"
abbrev: "Registering SLAAC Addresses using DHCPv6"
category: std
submissiontype: IETF

docname: draft-ietf-dhc-addr-notification-latest
submissiontype: IETF
ipr: trust200902
area: "Internet"
consensus: true
v: 3
workgroup: "Dynamic Host Configuration"
keyword: Internet-Draft
venue:
  group: "Dynamic Host Configuration"
  type: "Working Group"
  mail: "dhcwg@ietf.org"
  arch: "https://mailarchive.ietf.org/arch/browse/dhcwg/"
  github: "wkumari/draft-wkumari-dhc-addr-notification"
  latest: "https://wkumari.github.io/draft-wkumari-dhc-addr-notification/draft-wkumari-dhc-addr-notification.html"

stand_alone: yes
smart_quotes: no
pi: [toc, sortrefs, symrefs]

author:
  -
    name: Warren Kumari
    ins: W. Kumari
    organization: Google, LLC
    email: warren@kumari.net
  -
    name:  Suresh Krishnan
    ins: S. Krishnan
    org: Cisco Systems, Inc.
    email: suresh.krishnan@gmail.com
  -
    name: Rajiv Asati
    ins: R. Asati
    org: Cisco Systems, Inc.
    street:
    - 7025 Kit Creek road
    city: Research Triangle Park
    code: 27709-4987
    country: USA
    email: rajiva@cisco.com
  -
    name: Lorenzo Colitti
    ins: L. Colitti
    organization: Google, LLC
    street:
    - Shibuya 3-21-3
    country: Japan
    email: lorenzo@google.com
  -
    name: Jen Linkova
    ins: J. Linkova
    organization: Google, LLC
    street:
    - 1 Darling Island Rd
    city: Pyrmont
    code: 2009
    country: Australia
    email: furry@google.com
  -
    name: Sheng Jiang
    ins: S. Jiang
    organization: Beijing University of Posts and Telecommunications
    street:
    - No. 10 Xitucheng Road
    city: Beijing
    region: Haidian District
    code: 100083
    country: China
    email: shengjiang@bupt.edu.cn

contributor:
  -
    name: Gang Chen
    ins: G. Chen
    org: China Mobile
    street:
    - 53A, Xibianmennei Ave.
    - Xuanwu District
    city: Beijing
    country: P.R. China
    email: phdgang@gmail.com


normative:
  RFC2119:
  RFC4007:
  RFC4193:
  RFC4862:
  RFC6939:
  RFC8415:

informative:
  RFC6620:

--- abstract

This document defines a method to inform a DHCPv6 server that a device has a self-generated or statically configured address.


--- middle

# Introduction

It is very common operational practice, especially in enterprise networks, to use IPv4 DHCP logs for troubleshooting or security purposes. Examples of this include a help desk dealing with a ticket such as "The CEO's laptop cannot connect to the printer"; if the MAC address of the printer is known (for example from an inventory system), the IPv4 address can be retrieved from the DHCP logs and the printer pinged to determine if it is reachable. Another common example is a Security Operations team discovering suspicious events in outbound firewall logs and then consulting DHCP logs to determine which employee's laptop had that IPv4 address at that time so that they can quarantine it and remove the malware.

This operational practice relies on the DHCP server knowing the IP address assignments. Therefore, the practice does not work if static IP addresses are manually configured on devices or self-assigned addresses (such as when self-configuring an IPv6 address using SLAAC {{!RFC4862}}) are used.

The lack of this parity with IPv4 is one of the reasons which may be hindering IPv6 deployment, especially in enterprise networks.

This document provides a mechanism for a device to inform the DHCPv6 server that it has a self-configured IPv6 address (or has a statically configured address), and thus provides parity with IPv4 in this aspect.


# Conventions and Definitions

{::boilerplate bcp14-tagged}


# Registration Mechanism Overview

The DHCPv6 protocol is used as the address registration protocol when a DHCPv6 server performs the role of an address registration server.
This document introduces a new Address Registration (OPTION_ADDRESS_REG_ENABLE) option which indicates that the server supports the registration mechanism.
Before registering any addresses, the client sends an Information-Request message and includes the Address Registration option code
into the Option Request option (see Section 21.7 of {{!RFC8415}}).
If the server supports the address registration, it includes an Address Registration option into its Reply message.
The client MUST treat an absense of the Address Registration option in the Reply message as the explicit signal, indicating
that the server does not support (or is not willing to receive) any address registration information. 
Upon receiving a Reply message containing the Address Registration option, the client proceeds with registering the addresses.

After successfully assigning a self-generated IPv6 address on one of its interfaces, a client implementing this specification SHOULD multicast an ADDR-REG-INFORM message in order to inform the DHCPv6 server that this self-generated address is in use. Each ADDR-REG-INFORM message contains an DHCPv6 IA Address option {{!RFC8415}} to specify the address to being registered.

The address registration mechanism overview is shown in Fig.1. 

~~~~~~~~~~

+------+          +------------------+       +---------------+
| HOST |          | FIRST-HOP ROUTER |       | DHCPv6 SERVER |
+---+--+          +---------+--------+       +-------+-------+
    |      SLAAC            |                        |
    |<--------------------> |                        |
    |                       |                        |
    |                                                |
    |  src: link-local address                       |
    | -------------------------------------------->  |
    |    INFORMATION-REQUEST MESSAGE                 |
    |       - OPTION-REQUEST OPTION                  |
    |          -- OPTION_ADDRESS_REG_ENABLE code     |
    |                                                |
    |                                                |
    |                                                |
    |<---------------------------------------------  |
    |     REPLY MESSAGE                              |
    |       - ADDR_REG_ENABLE OPTION                 |
    |                                                |
    |                                                |
    |  src: address being registered                 |
    | -------------------------------------------->  |
    |    ADDR-REG-INFORM MESSAGE                     |Register/
    |                                                |log addresses
    |                                                |
    |                                                |
    | <--------------------------------------------  |
    |        ADD-REG-REPLY MESSAGE                   |
    |                                                |

~~~~~~~~~~

Figure 1: Address Registration Procedure Overview


# DHCPv6 Address Registration Procedure

## DHCPv6 Address Registration Option

The DHCPv6 server includes an Address Registration option (OPTION_ADDR_REG) to indicate that the server supports the mechanism described in this document.
The format of the Address Registration option is described as follows:


      0                   1                   2                   3
      0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |          option-code          |           option-len          |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

     option-code           OPTION_ADDR_REG (TBA0)

     option-len            0


Figure 2: DHCPv6 Address Registration option

A client SHOULD include this option in an Option-Request Option of the Information-Request message if the client has the address registration mechanism enabled.

A server which supports the address registration mechanism MUST include this option in a Reply message sent in response to a Information-Request message.

## DHCPv6 Address Registration Request Message

The DHCPv6 client sends an ADDR-REG-INFORM message to inform that an IPv6 address is in use.  The format of the ADDR-REG-INFORM message is described as follows:

      0                   1                   2                   3
      0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    msg-type   |               transaction-id                  |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |                                                               |
     .                            options                            .
     .                           (variable)                          .
     |                                                               |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      msg-type             Identifies the DHCPv6 message type;
                           Set to ADDR-REG-INFORM (TBA1).

      transaction-id       The transaction ID for this message exchange.

      options              Options carried in this message.

Figure 3: DHCPv6 ADDR-REG-INFORM message


The client MUST generate a transaction ID as described in [RFC8415] and insert this value in the "transaction-id" field.

The client MUST include a Client Identifier option in the ADDR-REG-INFORM message.

The ADDR-REG-INFORM message MUST NOT contain the Server Identifier option and MUST contain exactly one IA Address option containing the address being registered. The valid-lifetime and preferred-lifetime fields in the option MUST match the current Valid Lifetime and Preferred Lifetime of the address being registered.

The ADDR-REG-INFORM message is dedicated for clients to initiate an address registration request toward an address registration server.  Consequently, clients MUST NOT put any Option Request Option(s) in the ADDR-REG-INFORM message. Clients MAY include other options, such as the Client FQDN Option {{!RFC4704}}.

The client sends the DHCPv6 ADDR-REG-INFORM message to the All_DHCP_Relay_Agents_and_Servers multicast address (ff02::1:2). The client MUST send separate messages for each address being registered.

Unlike other types of messages, which are sent from the link-local address of the client, the ADDR-REG-INFORM message MUST be sent from the address being registered. This is primarily for "fate sharing" purposes - for example, if the network implements some form of L2 security to prevent a client from spoofing other clients' addresses this prevents an attacker from spoofing ADDR-REG-INFORM messages.

On clients with multiple interfaces, the client MUST only send the packet on the network interface that has the address being registered, even if it has multiple interfaces with different addresses. If the same address is configured on multiple interfaces, then the client MUST send ADDR-REG-INFORM each time the address is configured on an interface that did not previously have it, and refresh each registration independently from the others.

The client MUST only send the ADDR-REG-INFORM message for valid ({{!RFC4862}}) addresses of global scope ({{!RFC4007}}). This includes ULA addresses, which are defined in {{!RFC4193}} to have global scope.
The client MUST NOT send the  ADDR-REG-INFORM message for addresses configured by DHCPv6.

The client SHOULD NOT send the ADDR-REG-INFORM message if it has not received any Router Advertisement message with either M or O flags set to 1.

Clients MUST discard any received ADDR-REG-INFORM messages.

### Server message processing

Servers MUST discard any ADDR-REG-INFORM messages that meet any of the following conditions:

- the message does not include a Client Identifier option;
- the message includes a Server Identifier option;
- the message does not include the IA Address option, or the IP address in the IA Address option does not match the source address of the original ADDR-REG-INFORM message sent by the client. The source address of the original message is the source IP address of the packet if it is not relayed, or the Peer-Address field of the innermost Relay-Forward message if it is relayed.
- the message includes an Option Request Option.

If the message is not discarded, the address registration server SHOULD verify that the address being registered is "appropriate to the link" as defined by [RFC8415]. If the server believes that the address being registered is not appropriate to the link, it MUST drop the message, and SHOULD log this fact. Otherwise, the server:

*    SHOULD register or update a binding between the provided Client Identifier and IPv6 address in its database. The lifetime of the binding is equal to the Valid Lifetime of the address reported by the client. If there is already a binding between the registered address and another another client, the server SHOULD log the fact and update the binding.
*    SHOULD log the address registration information (as is done normally for clients to which it has assigned an address), unless configured not to do so.
*    SHOULD mark the address as unavailable for use and not include it in future ADVERTISE messages.
*    MUST send back an ADDR-REG-REPLY message to ensure the client does not retransmit.

Although a client "MUST NOT send the ADDR-REG-INFORM message for addresses configured by DHCPv6", if a server does receive such a message, it should log and discard it.

DHCPv6 relay agents and switches that relay address registration messages directly from clients SHOULD include the client's link-layer address in the relayed message using the Client Link-Layer Address option ({{!RFC6939}}).

## DHCPv6 Address Registration Acknowledgement

The server MUST acknowledge receipt of a valid ADDR-REG-INFORM message by sending back an ADDR-REG-REPLY message. The format of the ADDR-REG-REPLY message is described as follows:

      0                   1                   2                   3
      0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    msg-type   |               transaction-id                  |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |                                                               |
     .                            options                            .
     .                           (variable)                          .
     |                                                               |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      msg-type             Identifies the DHCPv6 message type;
                           Set to ADDR-REG-REPLY (TBA2).

      transaction-id       The transaction ID for this message exchange.

      options              Options carried in this message.

Figure 4: DHCPv6 ADDR-REG-REPLY message

If the ADDR-REG-INFORM message that the server is replying to was not relayed, then the IPv6 destination address of the message MUST be the address being registered. If the ADDR-REG-INFORM message was relayed, then the server MUST construct the Relay-reply message as specified in {{!RFC8415}} section 19.3.

The server MUST copy the transaction-id from the ADDR-REG-INFORM message to the transaction-id field of the ADDR-REG-REPLY.

The ADDR-REG-REPLY message MUST contain an IA Address option for the address being registered. The option MUST be identical to the one in the ADDR-REG-INFORM message that the server is replying to.

Servers MUST ignore any received ADDR-REG-REPLY messages.

Clients MUST discard any ADDR-REG-REPLY messages that meet any of the following conditions:

- The IPv6 destination address does not match the address being registered.
- The IA-Address option does not match the address being registered.
- The address being registered is not assigned to the interface receiving the message.
- The transaction-id does not match the transaction-id the client used in the corresponding ADDR-REG-INFORM message.

The ADDR-REG-REPLY message only indicates that the ADDR-REG-INFORM message has been received and that the client should not retansmit it. The ADDR-REG-REPLY message MUST NOT be considered as any indication of the address validity and MUST NOT be required for the address to be usable. DHCPv6 relays, or other devices that snoop ADDR-REG-REPLY messages, MUST NOT add or alter any forwarding or security state based on the ADDR-REG-REPLY message.

## Address Registration Support Signalling

To ensure that ADDR-REG-INFORM messages are only sent if there is at least one DHCPv6 server which supports the address registration mechanism, the client SHOULD send an Information-Request message when connecting to the network and performing IPv6 interface configuration.
After that, the client transmits periodic Information-request messages as per Section 18.2.6 of {{!RFC8415}}.
An Option Request option contained in that Information-Request message (see Section 18.1.5 of {{!RFC8415}}) MUST contain an Address Registration option code.

If no Reply messages received in response contain an Address Registration option, the client MUST NOT send any ADDR-REG-INFORM messages. If at least one Reply contains an Address Registration option, the client SHOULD start sending ADDR-REG-INFORM messages as described in this document.

When the client received an Address Registration option in an earlier Reply, then sends an Information-request and
the Address Registration option is not not present in the Reply, the client MUST stop sending ADDR-REG-INFORM messages
(see Section 18.2.10 of {{!RFC8415}}).


## Retransmission

To reduce the effects of packet loss on registration, the client SHOULD retransmit the registration message. Retransmissions SHOULD follow the standard retransmission logic specified by section 15 of [RFC8415] with the following default parameters:

*     IRT 1 sec
*     MRC 3

The client SHOULD allow these parameters to be configured by the administrator.

To comply with section 16.1 of [RFC8415], the client MUST leave the transaction ID unchanged in retransmissions of an ADDR-REG-INFORM message. When the client retranmits the registration message, the lifetimes in the packet MUST be updated so that they match the current lifetimes of the address.

If an ADDR-REG-REPLY message is received for the address being registered, the client MUST stop retransmission. However, the client cannot rely on the server acknowledging receipt of the registration message, because the server might not support address registration.


## Registration Expiry and Refresh

The client MUST refresh registrations to ensure that the server is always aware of which addresses are still valid. The client SHOULD perform refreshes as described below. Each refresh is scheduled for AddrRegRefresh seconds in the future, where AddrRegRefresh is min(4 hours, 80% of the address's current Valid Lifetime). Refreshes SHOULD be jittered by +/- 10% to avoid synchronization causing a large number of registration messages from different clients at the same time.

Whenever the client creates an address or receives a PIO which changes the Valid Lifetime of an existing address by more than 1%, then:

1. If no refresh is currently scheduled, it MUST register immediately and schedule a refresh.
1. If a refresh is currently scheduled, it MUST reschedule the existing refresh if this would result in the refresh being sooner than currently scheduled.

When a refresh is performed, the client MAY refresh all addresses assigned to the interface that are scheduled to be refreshed within the next AddrRegRefreshCoalesce seconds. The value of AddrRegRefreshCoalesce is implementation-dependent, and a suggested default is 60 seconds.

Discussion: this algorithm ensures that refreshes are not sent too frequently, while ensuring that the server never believes that the address has expired when it has not. Specifically:

- If the network never changes the lifetime, or stops refreshing the lifetime, then only one refresh ever occurs. The address expires.
- Point #1 ensures that any time the network changes the lifetime when no refresh is scheduled, the server will be informed of the correct lifetime. If the network does not change the address's lifetime, then the server already knows the correct lifetime and no refresh needs to be sent.
- Point #2 ensures that if the network reduces the lifetime of the address, then the server will be informed of the new lifetime. If the network increases the lifetime of the address, the refresh will be sent at the previously scheduled time, and the server will be informed of the correct lifetime. From this point on, either the address expires (and the server is informed of when this will happen) or an RA increases the lifetime, in which case a refresh will be sent.
- The 1% tolerance ensures that the client will not refresh or reschedule refreshes if the Valid Lifetime experiences minor changes due to transmission delays or clock skew between the client and the router(s) sending the Router Advertisement.
- AddrRegRefreshCoalesce allows battery-powered hosts to wake up less often. In particular, it allows the client to coalesce refreshes for multiple addresses formed from the same prefix, such as the stable and privacy addresses. Higher values will result in fewer wakeups, but may result in more network traffic, because if a refresh is sent early, then the next RA received will cause the client to immediately send a refresh message.

Registration refresh packets SHOULD be retransmitted using the same logic as described in the 'Retransmission' section above.

The client MUST generate a new transaction ID when refreshing the registration.

When the Client-Identifier-to-IPv6-address binding has expired, the server SHOULD remove it and consider the address as available for use.

The client MAY choose to notify the server when an address is no longer being used (e.g., if the client is disconnecting from the network, the address lifetime expired, or the address is being removed from the interface). To indicate that the address is not being used anymore the client MUST set the preferred-lifetime and valid-lifetime fields of the IA Address option to zero. If the server receives a message with a valid-lifetime of zero, it SHOULD act as if the address has expired.


# Host configuration

DHCP clients SHOULD allow the administrator to disable sending ADDR-REG-INFORM messages. This could be used, for example, to reduce network traffic on networks where the servers are known not to support the message type. Sending the messages SHOULD be enabled by default.


# Security Considerations

An attacker may attempt to register a large number of addresses in quick succession in order to overwhelm the address registration server and / or fill up log files. Similar attack vectors exist today, e.g. an attacker can DoS the server with messages contained spoofed DUIDs.

If a network is using FCFS SAVI [RFC6620], then the DHCPv6 server can trust that the ADDR-REG-INFORM message was sent by the legitimate holder of the address. This prevents a host from registering an address owned by another host.

One of the use cases for the mechanism described in this document is to identify sources of malicious traffic after the fact. Note, however, that as the device itself is responsible for informing the DHCPv6 server that it is using an address, a malicious or compromised device can simply not send the ADDR-REG-INFORM message. This is an informational, optional mechanism, and is designed to aid in troubleshooting and forensics. On its own, it is not intended to be a strong security access mechanism.
In particular, the ADDR-REG-INFORM message MUST not be used for authentication and authorization purposes, because in addition to the reasons above, the packets containing the message may be dropped.

# IANA Considerations

This document introduces the following new entities which require an allocation out of the DHCPv6 registries defined at http://www.iana.org/assignments/dhcpv6-parameters/:

*   one new DHCPv6 option (OPTION_ADDR_REG, TBA0, described in Section 4.1) which requires an allocation out of the registry of DHCPv6 Option Codes.
*   two new DHCPv6 messages which require an allocation out of the registry of Message Types:
    *  ADDR-REG-INFORM message (TBA1) described in Section 4.2
    *  ADDR-REG-REPLY (TBA2) described in Section 4.3.

--- back

# Acknowledgments
{:numbered="false"}

Many thanks to Bernie Volz for significant review and feedback, as well as Hermin Anggawijaya, Brian Carpenter, Stuart Cheshire, Alan DeKok, Ryan Globus, Erik Kline, David Lamparter, Ted Lemon, Eric Levy-Abegnoli, Jim Reid, Michael Richardson, Mark Smith, Éric Vyncke, Timothy Winters for their feedback, comments and guidance. We apologize if we inadvertently forgot to acknowledge anyone’s contributions.

This document borrows heavily from a previous document, draft-ietf-dhc-addr-registration, which defined "a mechanism to register self-generated and statically configured addresses in DNS through a DHCPv6 server". That document was written Sheng Jiang, Gang Chen, Suresh Krishnan, and Rajiv Asati.
