---
title: "Registering Self-generated IPv6 Addresses using DHCPv6"
abbrev: "Registering self-generated Addresses using DHCPv6"
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
    org: Independent
    email: rajiv.asati@gmail.com
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
    email: furry13@gmail.com
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
  RFC4861:

--- abstract

This document defines a method to inform a DHCPv6 server that a device has one or more self-generated or statically configured addresses.


--- middle

# Introduction

It is very common operational practice, especially in enterprise networks, to use IPv4 DHCP logs for troubleshooting or forensics purposes. Examples of this include a help desk dealing with a ticket such as "The CEO's laptop cannot connect to the printer"; if the MAC address of the printer is known (for example from an inventory system), the printer's IPv4 address can be retrieved from the DHCP log or lease table and the printer pinged to determine if it is reachable. Another common example is a Security Operations team discovering suspicious events in outbound firewall logs and then consulting DHCP logs to determine which employee's laptop had that IPv4 address at that time so that they can quarantine it and remove the malware.

This operational practice relies on the DHCP server knowing the IP address assignments. Therefore, the practice does not work if static IP addresses are manually configured on devices or self-assigned addresses (such as when self-configuring an IPv6 address using SLAAC {{!RFC4862}}) are used.

The lack of this parity with IPv4 is one of the reasons that may be hindering IPv6 deployment, especially in enterprise networks.

This document provides a mechanism for a device to inform the DHCPv6 server that the device has a self-configured IPv6 address (or has a statically configured address), and thus provides parity with IPv4 in this aspect.


# Conventions and Definitions

{::boilerplate bcp14-tagged}


# Registration Mechanism Overview

The DHCPv6 protocol is used as the address registration protocol when a DHCPv6 server performs the role of an address registration server.
This document introduces a new Address Registration (OPTION_ADDR_REG_ENABLE) option which indicates that the server supports the registration mechanism.
Before registering any addresses, the client MUST determine whether the network supports address registration. It can do this by including the Address Registration option code in the Option Request option (see Section 21.7 of [RFC8415]) of the Information-Request, Solicit, Request, Renew, or Rebind messages it sends to the server as part of the regular stateless or stateful DHCPv6 configuration process. If the server supports address registration, it includes an Address Registration option in its Advertise or Reply messages.
To avoid undesired multicast traffic, if the DHCPv6 infrastructure does not support (or is not willing to receive) any address registration information, the client MUST NOT register any addresses. Otherwise, the client registers addresses as described below.

After successfully assigning a self-generated or statically configured IPv6 address on one of its interfaces, a client implementing this specification SHOULD multicast an ADDR-REG-INFORM message (see Section 4.2) in order to inform the DHCPv6 server that this self-generated address is in use. Each ADDR-REG-INFORM message contains a DHCPv6 IA Address option {{!RFC8415}} to specify the address being registered.

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
    |    INFORMATION-REQUEST or SOLICIT/...          |
    |       - OPTION REQUEST OPTION                  |
    |          -- OPTION_ADDR_REG_ENABLE             |
    |                                                |
    |    ...                                         |
    |                                                |
    |                                                |
    |<---------------------------------------------  |
    |     REPLY MESSAGE                              |
    |       - OPTION_ADDR_REG_ENABLE                 |
    |                                                |
    |                                                |
    |  src: address being registered                 |
    | -------------------------------------------->  |
    |    ADDR-REG-INFORM MESSAGE                     |Register/
    |                                                |log addresses
    |                                                |
    |                                                |
    | <--------------------------------------------  |
    |        ADDR-REG-REPLY MESSAGE                  |
    |                                                |

~~~~~~~~~~

Figure 1: Address Registration Procedure Overview


# DHCPv6 Address Registration Procedure

## DHCPv6 Address Registration Option

The Address Registration option (OPTION_ADDR_REG_ENABLE) indicates that the server supports the mechanism described in this document. The format of the Address Registration option is described as follows:


      0                   1                   2                   3
      0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |          option-code          |           option-len          |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

     option-code           OPTION_ADDR_REG_ENABLE (TBA0)

     option-len            0


Figure 2: DHCPv6 Address Registration option

If a client has the address registration mechanism enabled, it SHOULD include this option in all Option Request options that it sends.

A server which is configured to support the address registration mechanism MUST include this option in Advertise and Reply messages if the client message it is replying to contained this option in the Option Request option.

## DHCPv6 Address Registration Request Message

The DHCPv6 client sends an ADDR-REG-INFORM message to inform that an IPv6 address is configured on the client's interface and can be used.
The format of the ADDR-REG-INFORM message is described as follows:

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

The client MUST include the Client Identifier option [RFC8415] in the ADDR-REG-INFORM message.

The ADDR-REG-INFORM message MUST NOT contain the Server Identifier option and MUST contain exactly one IA Address option containing the address being registered. The valid-lifetime and preferred-lifetime fields in the option MUST match the current Valid Lifetime and Preferred Lifetime of the address being registered.

The ADDR-REG-INFORM message is dedicated for clients to initiate an address registration request toward an address registration server.  Consequently, clients MUST NOT put any Option Request Option(s) in the ADDR-REG-INFORM message. Clients MAY include other options, such as the Client FQDN Option {{!RFC4704}}.

The client sends the DHCPv6 ADDR-REG-INFORM message to the All_DHCP_Relay_Agents_and_Servers multicast address (ff02::1:2). The client MUST send separate messages for each address being registered.

Unlike other types of messages, which are sent from the link-local address of the client, the ADDR-REG-INFORM message MUST be sent from the address being registered. This is primarily for "fate sharing" purposes - for example, if the network implements some form of layer-2 security to prevent a client from spoofing other clients' MAC addresses, this prevents an attacker from spoofing ADDR-REG-INFORM messages.

On clients with multiple interfaces, the client MUST only send the packet on the network interface that has the address being registered, even if it has multiple interfaces with different addresses. If the same address is configured on multiple interfaces, then the client MUST send ADDR-REG-INFORM each time the address is configured on an interface that did not previously have it, and refresh each registration independently from the others.

The client MUST only send the ADDR-REG-INFORM message for valid ({{!RFC4862}}) addresses of global scope ({{!RFC4007}}). This includes ULA addresses, which are defined in {{!RFC4193}} to have global scope. This also includes statically assigned addresses of global scope (such addresses are considered to be valid indefinitely).
The client MUST NOT send the ADDR-REG-INFORM message for addresses configured by DHCPv6.

The client SHOULD NOT send the ADDR-REG-INFORM message if it has not received any Router Advertisement message with either M or O flags set to 1.

Clients MUST discard any received ADDR-REG-INFORM messages.

### Server message processing

Servers MUST discard any ADDR-REG-INFORM messages that meet any of the following conditions:

- the message does not include a Client Identifier option;
- the message includes a Server Identifier option;
- the message does not include the IA Address option, or the IP address in the IA Address option does not match the source address of the original ADDR-REG-INFORM message sent by the client. The source address of the original message is the source IP address of the packet if it is not relayed, or the Peer-Address field of the innermost Relay-Forward message if it is relayed.
- the message includes an Option Request Option.

If the message is not discarded, the address registration server SHOULD verify that the address being registered is "appropriate to the link" as defined by [RFC8415] or within a prefix delegated to the client via DHCPv6-PD (see Section 6.3 of {{!RFC8415}}). Otherwise, it MUST drop the message, and SHOULD log this fact. Otherwise, the server:

*    SHOULD register or update a binding between the provided Client Identifier and IPv6 address in its database. The lifetime of the binding is equal to the Valid Lifetime of the address reported by the client. If there is already a binding between the registered address and another client, the server SHOULD log the fact and update the binding.
*    SHOULD log the address registration information (as is done normally for clients to which it has assigned an address), unless configured not to do so. The server SHOULD log the client DUID and the link-layer address, if available. The server MAY log any other information.
*    SHOULD mark the address as unavailable for use and not include it in future ADVERTISE messages.
*    MUST send back an ADDR-REG-REPLY message to ensure the client does not retransmit.

If a client is multihomed (connected to multiple administrative domains, each operating its own DHCPv6 infrastructure), the requirement to verify that the registered address is appropriate for the link or  belongs to a delegated prefix ensures that each DHCPv6 server only registers bindings for addresses from the given administrative domain.

Although a client "MUST NOT send the ADDR-REG-INFORM message for addresses configured by DHCPv6", if a server does receive such a message, it should log and discard it.

DHCPv6 relay agents and switches that relay address registration messages directly from clients MUST include the client's link-layer address in the relayed message using the Client Link-Layer Address option ({{!RFC6939}}) if they would do so for other DHCPv6 client messages such as SOLICIT, REQUEST, and REBIND.

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
- The IA Address option does not match the address being registered.
- The address being registered is not assigned to the interface receiving the message.
- The transaction-id does not match the transaction-id the client used in the corresponding ADDR-REG-INFORM message.

The ADDR-REG-REPLY message only indicates that the ADDR-REG-INFORM message has been received and that the client should not retransmit it. The ADDR-REG-REPLY message MUST NOT be considered as any indication of the address validity and MUST NOT be required for the address to be usable. DHCPv6 relays, or other devices that snoop ADDR-REG-REPLY messages, MUST NOT add or alter any forwarding or security state based on the ADDR-REG-REPLY message.

## Signaling Address Registration Support

To avoid undesired multicast traffic, the client MUST NOT register addresses using this mechanism unless the network's DHCPv6 servers support address registration. The client can discover this using the OPTION_ADDR_REG_ENABLE option. The client SHOULD include this option code in all Option Request options that it sends. If the client receives and processes an Advertise or Reply message with the OPTION_ADDR_REG_ENABLE option, it concludes that the network supports address registration. When the client detects that the network supports address registration, it SHOULD start the registration process and immediately register any addresses that are already in use. The client SHOULD NOT stop registering addresses until it disconnects from the link, even if subsequent Advertise or Reply messages do not contain the OPTION_ADDR_REG_ENABLE option.

The client MUST discover whether the network supports address registration every time it connects to a network or when it detects it has moved to a new link, without utilizing any prior knowledge about address registration support by that network or link. This host behavior allows networks to progressively roll out support for the address registration option across the DHCPv6 infrastructure without causing clients to frequently stop and restart address registration if some of the network's DHCPv6 servers support it and some of them do not.

## Retransmission

To reduce the effects of packet loss on registration, the client SHOULD retransmit the registration message. Retransmissions SHOULD follow the standard retransmission logic specified by section 15 of [RFC8415] with the following default parameters:

*     IRT 1 sec
*     MRC 3

The client SHOULD allow these parameters to be configured by the administrator.

To comply with section 16.1 of [RFC8415], the client MUST leave the transaction ID unchanged in retransmissions of an ADDR-REG-INFORM message. When the client retransmits the registration message, the lifetimes in the packet MUST be updated so that they match the current lifetimes of the address.

If an ADDR-REG-REPLY message is received for the address being registered, the client MUST stop retransmission.

## Registration Expiry and Refresh

The client MUST refresh registrations to ensure that the server is always aware of which addresses are still valid. The client SHOULD perform refreshes as described below.

A function AddrRegRefreshInterval(address) is defined as min(4 hours, 80% of the address's current Valid Lifetime). When calculating this value, the client applies a multiplier of AddrRegDesyncMultiplier to avoid synchronization causing a large number of registration messages from different clients at the same time. AddrRegDesyncMultiplier is a random value uniformly distributed between 0.9 and 1.1 (inclusive) and is chosen by the client when it starts the registration process, to ensure that refreshes for addresses with the same lifetime are coalesced (see below).

Whenever the client registers or refreshes an address, it calculates a NextAddrRegRefreshTime for that address as AddrRegRefreshInterval seconds in the future but does not schedule any refreshes.

Whenever the client receives a Prefix Information option (PIO, [RFC4861]) which changes the Valid Lifetime of an existing address by more than 1%, then the client calculates a new AddrRegRefreshInterval. The client schedules a refresh for min(now + AddrRegRefreshInterval, NextAddrRegRefreshTime). If the refresh would be scheduled in the past, then the refresh occurs immediately.

When a refresh is performed, the client MAY refresh all addresses assigned to the interface that are scheduled to be refreshed within the next AddrRegRefreshCoalesce seconds. The value of AddrRegRefreshCoalesce is implementation-dependent, and a suggested default is 60 seconds.

Justification: this algorithm ensures that refreshes are not sent too frequently, while ensuring that the server never believes that the address has expired when it has not. Specifically, after every registration:

- If the client never receives a PIO that changes the lifetime (e.g., if no further PIOs are received, or if all PIO lifetimes decrease in step with the passage of time), then no refreshes occur. Refreshes are not necessary, because the address expires at the time the server expects it to expire.
- Any time a PIO changes the lifetime of the address (i.e., changes the time at which the address will expire) the client ensures that a refresh is scheduled, so that server will be informed of the new expiry.
- Because AddrRegDesyncMultiplier is at most 1.1, the refresh never occurs later than a point 88% between the time when the address was registered and the time when the address will expire. This allows the client to retransmit the registration for up to 12% of the original interval before it expires. This may not be possible if the network sends a Router Advertisement (RA, [RFC4861]) very close to the time when the address would have expired. In this case, the client refreshes immediately, which is the best it can do.
- The 1% tolerance ensures that the client will not refresh or reschedule refreshes if the Valid Lifetime experiences minor changes due to transmission delays or clock skew between the client and the router(s) sending the Router Advertisement.
- AddrRegRefreshCoalesce allows battery-powered hosts to wake up less often. In particular, it allows the client to coalesce refreshes for multiple addresses formed from the same prefix, such as the stable and privacy addresses. Higher values will result in fewer wakeups, but may result in more network traffic, because if a refresh is sent early, then the next RA received will cause the client to immediately send a refresh message.
- In typical networks, the lifetimes in periodic Router Advertisements either contain constant values, or values that decrease over time to match another lifetime, such as the lifetime of a prefix delegated to the network. In both these cases, this algorithm will refresh on the order of once per address lifetime, which is similar to the number of refreshes that are necessary using stateful DHCPv6.

Registration refresh packets SHOULD be retransmitted using the same logic as described in the 'Retransmission' section above.

The client MUST generate a new transaction ID when refreshing the registration.

When the Client-Identifier-to-IPv6-address binding has expired, the server SHOULD remove it and consider the address as available for use.

The client MAY choose to notify the server when an address is no longer being used (e.g., if the client is disconnecting from the network, the address lifetime expired, or the address is being removed from the interface). To indicate that the address is not being used anymore the client MUST set the preferred-lifetime and valid-lifetime fields of the IA Address option in the ADDR-REG-INFORM message to zero. If the server receives a message with a valid-lifetime of zero, it SHOULD act as if the address has expired.


# Host configuration

DHCP clients SHOULD allow the administrator to disable sending ADDR-REG-INFORM messages. This could be used, for example, to reduce network traffic on networks where the servers are known not to support the message type. Sending the messages SHOULD be enabled by default.


# Security Considerations

An attacker may attempt to register a large number of addresses in quick succession in order to overwhelm the address registration server and / or fill up log files. Similar attack vectors exist today, e.g., an attacker can DoS the server with messages containing spoofed DHCP Unique Identifiers (DUIDs) {{!RFC8415}}.

If a network is using FCFS SAVI [RFC6620], then the DHCPv6 server can trust that the ADDR-REG-INFORM message was sent by the legitimate holder of the address. This prevents a host from registering an address configured on another host.

If the network doesn't have MLD snooping enabled, then IPv6 link-local multicast traffic is effectively transmitted as broadcast.
In such networks, an on-link attacker listening to DHCPv6 messages might obtain information about IPv6 addresses assigned to the host.
However, hiding information about the specific IPv6 address should not be considered a security measure, as such information is usually disclosed via Duplicate Address Detection {{!RFC4862}} to all nodes anyway, if MLD snooping is not enabled.


If MLD snooping is enabled, an attacker might be able to join the All_DHCP_Relay_Agents_and_Servers multicast address (ff02::1:2) group to listen for address registration messages.
However, the same result can be achieved by joining the All Routers Address (ff02::2) group and listen to Gratuitous Neighbor Advertisement messages {{!RFC9131}}. It should be noted that this particular scenario shares the fate with DHCPv6 address assignment: if an attacker can join the All_DHCP_Relay_Agents_and_Servers multicast group, they would be able to monitor all DHCPv6 messages sent from the client to DHCPv6 servers and relays, and therefore obtain the information about addresses being assigned via DHCPv6.
Layer 2 isolation allows mitigating this threat by blocking onlink peer-to-peer communication between hosts.


One of the use cases for the mechanism described in this document is to identify sources of malicious traffic after the fact. Note, however, that as the device itself is responsible for informing the DHCPv6 server that it is using an address, a malicious or compromised device can simply not send the ADDR-REG-INFORM message. This is an informational, optional mechanism, and is designed to aid in troubleshooting and forensics. On its own, it is not intended to be a strong security access mechanism.
In particular, the ADDR-REG-INFORM message MUST NOT be used for authentication and authorization purposes, because in addition to the reasons above, the packets containing the message may be dropped.

# IANA Considerations

This document introduces the following new entities which require an allocation out of the DHCPv6 registries defined at http://www.iana.org/assignments/dhcpv6-parameters/:

*   one new DHCPv6 option, described in Section 4.1 which requires an allocation out of the registry of DHCPv6 Option Codes:
    * Value: TBA0
    * Description: OPTION_ADDR_REG_ENABLE
    * Client ORO: Yes
    * Singleton Option: Yes
*   two new DHCPv6 messages which require an allocation out of the registry of Message Types:
    *  ADDR-REG-INFORM message (TBA1) described in Section 4.2
    *  ADDR-REG-REPLY (TBA2) described in Section 4.3.

--- back

# Acknowledgments
{:numbered="false"}

Many thanks to Bernie Volz for significant review and feedback, as well as Hermin Anggawijaya, Brian Carpenter, Stuart Cheshire, Alan DeKok, James Guichard, James Guichard, Erik Kline, Mallory Knodel, David Lamparter, Ted Lemon, Eric Levy-Abegnoli, Aditi Patange, Jim Reid, Michael Richardson, Mark Smith, Gunter Van de Velde, Eric Vyncke, Timothy Winters, Peter Yee for their feedback, comments and guidance. We apologize if we inadvertently forgot to acknowledge anyone's contributions.

This document borrows heavily from a previous document, draft-ietf-dhc-addr-registration, which defined "a mechanism to register self-generated and statically configured addresses in DNS through a DHCPv6 server". That document was written Sheng Jiang, Gang Chen, Suresh Krishnan, and Rajiv Asati.
