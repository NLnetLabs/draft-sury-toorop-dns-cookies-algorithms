%%%
Title = "Interoperable Domain Name System (DNS) Server Cookies"
abbrev = "server-cookies"
docname = "@DOCNAME@"
category = "std"
ipr = "trust200902"
area = "Internet"
workgroup = "DNSOP Working Group"
updates = [7873]
date = 2019-09-09T09:00:00Z

[seriesInfo]
name = "Internet-Draft"
value = "@DOCNAME@"
stream = "IETF"
status = "standard"

[[author]]
initials = "O."
surname = "Sury"
fullname = "Ondrej Sury"
organization = "Internet Systems Consortium"
[author.address]
 email = "ondrej@isc.org"
[author.address.postal]
 country = "CZ"

[[author]]
initials="W."
surname="Toorop"
fullname="Willem Toorop"
organization = "NLnet Labs"
[author.address]
 email = "willem@nlnetlabs.nl"
[author.address.postal]
 street = "Science Park 400"
 city = "Amsterdam"
 code = "1098 XH"
 country = "Netherlands"

[[author]]
initials="D."
surname="Eastlake 3rd"
fullname="Donald E. Eastlake 3rd"
organization = "Futurewei Technologies"
[author.address]
 phone = "+1-508-333-2270"
 email = "d3e3e3@gmail.com"
[author.address.postal]
 street = "1424 Pro Shop Court"
 city = "Davenport"
 code = "FL 33896"
 country = "USA"

[[author]]
initials="M."
surname="Andrews"
fullname="Mark Andrews"
organization = "Internet Systems Consortium"
[author.address]
 email = "marka@isc.org"
[author.address.postal]
 street = "950 Charter Street"
 city = "Redwood City"
 code = "CA 94063"
 country = "USA"
%%%


.# Abstract

DNS cookies, as specified in RFC 7873, are a lightweight DNS transaction
security mechanism that provides limited protection to DNS servers and
clients against a variety of denial-of-service and amplification, forgery,
or cache poisoning attacks by off-path attackers.

This document provides precise directions for creating Server Cookies so
that an anycast server set including diverse implementations will
interoperate with standard clients.

This document updates [@!RFC7873]

{mainmatter}

# Introduction

DNS cookies, as specified in [@!RFC7873], are a lightweight DNS transaction
security mechanism that provides limited protection to DNS servers and
clients against a variety of denial-of-service and amplification, forgery,
or cache poisoning attacks by off-path attackers. This document specifies a
means of producing interoperable strong cookies so that an anycast server
set including diverse implementations can be easily configured to
interoperate with standard clients.

The threats considered for DNS Cookies and the properties of the DNS
Security features other than DNS Cookies are discussed in [@!RFC7873].

In [@!RFC7873] in Section 6 it is "RECOMMENDED for simplicity that
the same Server Secret be used by each DNS server in a set of anycast
servers."  However, how precisely a Server Cookie is calculated from
this Server Secret, is left to the implementation.

This guidance has led to a gallimaufry of DNS Cookie implementations,
calculating the Server Cookie in different ways. As a result, DNS Cookies
are impractical to deploy on multi-vendor anycast networks, because even
when all DNS Software share the same secret, as RECOMMENDED in Section
6 of [@!RFC7873], the Server Cookie constructed by one implementation
cannot generally be validated by another.

There is no need for DNS client (resolver) Cookies to be interoperable
across different implementations. Each client need only be able to recognize
its own cookies. However, this document does contain recommendations for
constructing Client Cookies in a Client protecting fashion.

## Contents of this document

Section (#changes) summarises the changes to [@!RFC7873].

In Section (#clientCookie) suggestions for constructing a Client
Cookie are given.

In Section (#serverCookie) instructions for constructing a Server 
Cookie are given.

In Section (#rollingSecret) instructions on updating Server Secrets are given.

In Section (#cookieAlgorithms) the different hash functions usable for DNS
Cookie construction are listed.  [@FNV] and HMAC-SHA-256-64 [@RFC6234] are
deprecated and [@!SipHash-2.4] is introduced as a REQUIRED hash function for
server side DNS Cookie implementations.

IANA considerations are in (#ianaConsiderations).

Acknowledgements are in (#acknowledgements).

Test vectors are in (#testVectors).

## Definitions

The key words "**MUST**", "**MUST NOT**", "**REQUIRED**", 
"**SHALL**", "**SHALL NOT**", "**SHOULD**", "**SHOULD NOT**",
"**RECOMMENDED**", "**NOT RECOMMENDED**", "**MAY**", and
"**OPTIONAL**" in this document are to be interpreted as described in
BCP 14 [@!RFC2119] [@!RFC8174] when, and only when, they appear in all
capitals, as shown here.

* "IP Address" is used herein as a length independent term covering
   both IPv4 and IPv6 addresses.

# Changes to [RFC7873] {#changes}

In its Appendices A.1 and B.1, [@!RFC7873] provides example "simple" algorithms
for computing Client and Server Cookies, respectively.  These algorithms MUST
NOT be used as the resulting cookies are too weak when evaluated against modern
security standards.

In its Appendix B.2, [RFC7873] provides an example "more complex" server
algorithm. This algorithm is replaced by the interoperable specification in
(#serverCookie) of this document, which MUST be used by Server Cookie
implementations.

This document has suggestions on Client Cookie construction in (#clientCookie).
The previous example in Appendix A.2 of [@!RFC7873] is NOT RECOMMENDED.

# Constructing a Client Cookie {#clientCookie}

The Client Cookie is a **cryptographic** nonce and should be treated as such.
For simplicity, it can be calculated from Server IP Address, and a secret known
only to the Client. The Client Cookie SHOULD have at least 64-bits of entropy.

It is RECOMMENDED but not required that the following pseudorandom function be
used to construct the Client Cookie:

~~~ ascii-art
Client-Cookie = MAC_Algorithm(
    Server IP Address, Client Secret )
~~~

Previously, the recommended algorithm to compute the Client Cookie included
Client IP Address as an input to the MAC_Algorithm.  However, when implementing
the DNS Cookies, several DNS vendors found impractical to include the Client IP
as the Client Cookie is typically computed before the Client IP address is
known.  Therefore, the requirement to put Client IP address as input to was
removed.

However, for privacy reasons, in order to prevent tracking of devices across
links and to not circumvent IPv6 Privacy Extensions [RFC4941], Clients MUST
NOT re-use a Client or Server Cookie after the Client IP address has changed.

The Client IP address is available on the UDP socket when it received the
Server Cookie and can be stored for the Server alongside the Server Cookie.
In subsequent queries to that Server with the Server Cookie, the socket MUST 
be bound to the Client IP address that was also used when it learned the Server
Cookie. Failure to bind must result in a new Client Cookie, which, for the
method described in this section means a new Client Secret.

# Constructing a Server Cookie {#serverCookie}

The Server Cookie is effectively a Message Authentication Code (MAC) and should
be treated as such.  The Server Cookie is calculated from the Client Cookie,
a series of Sub-Fields specified below, the Client IP address, and a Server
Secret known only to the servers responding on the same address in an anycast set.

Changing the Server Secret regularly is RECOMMENDED but, when a secure
pseudorandom function is used, it need not be changed too frequent.  For
example once a month would be adequate.  See (#rollingSecret) on operator and
implementation guidelines for updating a Server Secret.

The 128-bit Server Cookie consists of Sub-Fields: a 1 octet Version Sub-Field,
a 3 octet Reserved Sub-Field, a 4 octet Timestamp Sub-Field and an 8 octet Hash
Sub-Field.

~~~ ascii-art
 0                   1                   2                   3
 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|    Version    |                   Reserved                    |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                           Timestamp                           |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                             Hash                              |
|                                                               |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
~~~

## The Version Sub-Field

The Version Sub-Field prescribes the structure and Hash calculation formula.
This document defines Version 1 to be the structure and way to calculate the
Hash Sub-Field as defined in this Section.

## The Reserved Sub-Field

The value of the Reserved Sub-Field is reserved for future versions of Server
Side Cookie construction.  On construction it SHOULD be set to zero octets.  On
Server Cookie verification the server MUST NOT enforce those fields to be zero
and the Hash should be computed with the received value as described in
(#hashField).

## The Timestamp Sub-Field {#timestampField}

The Timestamp value prevents Replay Attacks and MUST be checked by the server
to be within a defined period of time.  The DNS Server SHOULD allow Cookies
within 1 hour period in the past and 5 minutes into the future to allow
operation of low volume clients and some limited time skew between the DNS
servers in the anycast.

The Timestamp value specifies a date and time in the form of a 32-bit unsigned
number of seconds elapsed since 1 January 1970 00:00:00 UTC, ignoring leap
seconds, in network byte order.  All comparisons involving these fields MUST
use "Serial number arithmetic", as defined in [@!RFC1982]

The DNS Server SHOULD generate a new Server Cookie at least if the received
Server Cookie from the Client is more than half an hour old.

## The Hash Sub-Field {#hashField}

It's important that all the DNS servers use the same algorithm for computing
the Server Cookie.  This document defines the Version 1 of the Server Side
algorithm to be:

~~~ ascii-art
Hash = SipHash2.4(
    Client Cookie | Version | Reserved | Timestamp | Client-IP,
    Server Secret )
~~~

where "|" indicates concatenation.

Notice that Client-IP is used for hash generation even though it's not included
in the cookie value itself. Client-IP can be either 4 bytes for IPv4 or 16
bytes for IPv6.

The Server Secret MUST be configurable to make sure that servers in an anycast
network return consistent results.

# Updating the Server Secret {#rollingSecret}

All servers in an anycast group must be able to verify the Server Cookies
constructed by all other servers in that anycast set at all times.  Therefore
it is vital that the Server Secret is shared among all servers before it us
used to generate Server Cookies.

Also, to maximize maintaining established relationships between clients and
servers, an old Server Secret should be valid for verification purposes for a
specific period.

To facilitate this, deployment of a new Server Secret MUST be done in three
stages:

Stage 1
: The new Server Secret is deployed on all the servers in an anycast set by
  the operator.

> Each server learns the new Server Secret, but keeps using the previous Server
  Secret to generate Server Cookies.

> Server Cookies constructed with the both the new Server Secret and with
  the previous Server Secret are considered valid when verifying.

> After stage 1 completed, all the servers in the anycast set have learned the
  new Server Secret, and can verify Server Cookies constructed with it, but keep
  generating Server Cookies with the old Server Secret.

Stage 2
: This stage is initiated by the operator after the Server Cookie is present
  on all members in the anycast set.

> When entering Stage 2, servers start generating Server Cookies with the new
  Server Secret. The previous Server Secret is not yet removed/forgotten about.

> Server Cookies constructed with the both the new Server Secret and with
  the previous Server Secret are considered valid when verifying.

Stage 3
: This stage is initiated by the operator when it can be assumed that most
  clients have learned the new Server Secret.

> With this stage, the previous Server Secret can be removed and MUST NOT be
  used anymore for verifying.

> We RECOMMEND the operator to wait at least a period to be the longest TTL in
  the zones served by the server plus half an hour after it initiated Stage 2,
  before initiating Stage 3.

> The operator SHOULD wait at least longer than the period clients are allowed
  to use the same Server Cookie, which SHOULD be half an hour,
  see (#timestampField).

# Cookie Algorithms {#cookieAlgorithms}

[@!SipHash-2.4] is a pseudorandom function suitable as Message Authentication
Code.  This document REQUIRES compliant DNS Server to use SipHash-2.4 as a
mandatory and default algorithm for DNS Cookies to ensure interoperability
between the DNS Implementations.

The construction method and pseudorandom function used in calculating and
verifying the Server Cookies are determined by the initial version byte and by
the length of the Server Cookie. Additional pseudorandom or construction
algorithms for Server Cookies might be added in the future.

# IANA Considerations {#ianaConsiderations}

IANA is requested to create a registry on the "Domain Name System (DNS) Parameters"
IANA web page as follows:

Registry Name: DNS Server Cookie Methods\\
Assignment Policy: Expert Review\\
Reference: [this document], [RFC7873]\\
Note: Server Cookie method (construction and pseudorandom algorithm) are
determined by the Version in the first byte of the Cookie and by the Cookie
size. Server Cookie size is limited to the inclusive range of 8 to 32 bytes.

Implementation recommendations for Cookie Algorithms [DNSCOOKIE-IANA]:

Version | Size  | Method 
-------:|------:|:--------------------
0       |  8-32 | reserved
1       |  8-15 | unassiged
1       |    16 | SipHash-2.4 \[this document\] (#serverCookie)
1       | 17-32 | unassigned
2-239   |  8-32 | unassigned
240-254 |  8-32 | private use
255     |  8-32 | reserved

<reference anchor='FNV' target='https://datatracker.ietf.org/doc/draft-eastlake-fnv'>
    <front>
        <title>The FNV Non-Cryptographic Hash Algorithm</title>
	<author fullname="Glenn Fowler" initials="G." surname="Fowler" />
	<author fullname="Landon Curt Noll" initials="L." surname="Noll" />
	<author fullname="Kiem-Phong Vo" initials="K." surname="Vo" />
	<author fullname="Donald Eastlake" initials="D." surname="Eastlake" />
	<author fullname="Tony Hansen" initials="T." surname="Hansen" />
	<date/>
    </front>
</reference>

<reference anchor='SipHash-2.4' target='https://131002.net/siphash/'>
    <front>
        <title>SipHash: a fast short-input PRF</title>
	<author fullname="Jean-Philippe Aumasson" initials="J." surname="Aumasson" />
	<author fullname="Daniel J. Bernstein" initials="D. J." surname="Bernstein" />
	<date year="2012"/>
    </front>
</reference>

{backmatter}

# Acknowledgements {#acknowledgements}

Thanks to Witold Krecicki and Pieter Lexis for valuable input, suggestions and
text and above all for implementing a prototype of an interoperable DNS Cookie
in Bind9, Knot and PowerDNS during the hackathon of IETF104 in Prague.  Thanks
for valuable input and suggestions go to Ralph Dolmans, Bob Harold, Daniel
Salzman, Martin Hoffmann, Mukund Sivaraman, Petr Spacek, Loganaden Velvindron,
Bob Harold and Philip Homburg

{{test-vectors.md}}