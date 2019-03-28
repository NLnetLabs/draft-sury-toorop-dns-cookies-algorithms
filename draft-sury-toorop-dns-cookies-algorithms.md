%%%
Title = "Algorithms for Domain Name System (DNS) Cookies construction"
abbrev = "dns-cookies-algorithms"
docname = "@DOCNAME@"
category = "std"
ipr = "trust200902"
area = "Internet"
workgroup = "DNSOP Working Group"
updates = [7873]
date = 2019-03-11T00:00:00Z

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
%%%


.# Abstract

[@!RFC7873] left the construction of Server Cookies to the discretion
of the DNS Server (implementer) which has resulted in a gallimaufry of
different implementations.  As a result, DNS Cookies are impractical
to deploy on multi-vendor anycast networks, because the Server Cookie
constructed by one implementation cannot be validated by another.

This document provides precise directions for creating Server Cookies to
address this issue.  It also obsoletes all the previous mechanisms of cookie
generation as they were either insecure as [@FNV], slow as SHA, or the
description wasn't precise enough for implementers. [@SipHash-2.4] is
introduced as a new REQUIRED Hash function for calculating DNS Cookies.

This document updates [@!RFC7873]


{mainmatter}

# Introduction

In [@!RFC7873] in Section 6 it is "RECOMMENDED for simplicity that
the Same Server Secret be used by each DNS server in a set of anycast
servers."  However, how precisely a Server Cookie is calculated from
this Server Secret, is left to the implementation.

This guidance has let to DNS Cookie implementations, calculating the
Server Cookie in different ways.  This causes problems with anycast
deployments with DNS Software from multiple vendors, because even when
all DNS Software would share the same secret, as RECOMMENDED in Section
6.  of [@!RFC7873], they all produce different Server Cookies based on
that secret and (at least) the Client Cookie and Client IP Address.

## Contents of this document

In Section (#clientCookie) instructions for constructing a Client
Cookie are given

In Section (#serverCookie) instructions for constructing a Server 
Cookie are given

In Section (#cookieAlgorithms) the different hash functions usable
for DNS Cookie construction are listed.  [@FNV] and HMAC-SHA-256-64
[@!RFC6234] are obsoleted and AES [@!RFC5649] and [@SipHash-2.4] are
introduced as a REQUIRED hash function for DNS Cookie
implementations.

## Definitions

The key words "**MUST**", "**MUST NOT**", "**REQUIRED**", 
"**SHALL**", "**SHALL NOT**", "**SHOULD**", "**SHOULD NOT**",
"**RECOMMENDED**", "**NOT RECOMMENDED**", "**MAY**", and
"**OPTIONAL**" in this document are to be interpreted as described in
BCP 14 [@!RFC2119] [@!RFC8174] when, and only when, they appear in all
capitals, as shown here.


# Constructing a Client Cookie {#clientCookie}

The Client Cookie is a nonce and should be treated as such.  For simplicity,
it can be calculated from Client IP Address, Server IP Address and a secret
known only to the Client.  The Client Cookie SHOULD have at least 64-bits
of entropy.  If a secure pseudorandom function (like SipHash24) is used there's
no need to change Client secret periodically and change the Client secret only
if it has been compromised.

It's recommended but not required that a pseudorandom function is used to
construct the Client Cookie:

~~~ ascii-art
Client-Cookie = MAC_Algorithm(
    Client IP Address | Server IP Address, Client Secret )
~~~

where "|" indicates concatenation.

# Constructing a Server Cookie {#serverCookie}

The Server Cookie is effectively message authentication code (MAC) and should be
treated as such.

The Server Cookie is not required to be changed periodically if a secure
pseudorandom function is used.

The 128-bit Server Cookie consists of Sub-Fields: a 1 octet Version
Sub-Field, a 1 octet Cookie Algorithm Sub-Field, a 2 octet Reserved
Sub-Field, a 4 octet Timestamp Sub-Field and a 8 octet Hash Sub-Field.

~~~ ascii-art
 0                   1                   2                   3
 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|    Version    |  Cookie Algo  |           Reserved            |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                           Timestamp                           |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                             Hash                              |
|                                                               |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
~~~

## The Version Sub-Field

The Version Sub-Field prescribes the structure and Hash calculation
formula.  This document defines Version 1 to be the structure and way to
calculate the Hash Sub-Field as defined in this Section.

## The Cookie algo Sub-Field

The Cookie Algo value defines what algorithm function to use for 
calculating the Hash Sub-Field as described in (#hashField).  The values
are described in (#cookieAlgorithms).

## The Reserved Sub-Field

The value of the Reserved Sub-Field is reserved for future versions of Server
Side Cookie construction.  On construction it SHOULD be set to zero octets.  On
Server Cookie verification the server MUST NOT enforce those fields to be zero
and the has should be computed with the received value as described in
(#hashField).

## The Timestamp Sub-Field

The Timestamp value prevents Replay Attacks and MUST be checked by the server to
be within a defined period of time.  The DNS Server SHOULD allow Cookies within
1 hour period in the past and 5 minutes into the future to allow operation of
low volume clients and certain time skew between the DNS servers in the anycast.

The DNS Server SHOULD generate new Server Cookie at least if the received Server
Cookie from the Client is older than half an hour.

## The Hash Sub-Field {#hashField}

It's important that all the DNS servers use the same algorithm for computing the
Server Cookie.  This document defines the Version 1 of the Server Side algorithm
to be:

~~~ ascii-art
Hash = Cookie_Algorithm(
    Client Cookie | Version | Cookie Algo | Reserved | TimeStamp | Client-IP,
    Server Secret )
~~~

Notice that Client-IP is used for hash generation even though it's not
included in the cookie value itself. Client-IP can be either 4 bytes for
IPv4 or 16 bytes for IPv6.

# Cookie Algorithms {#cookieAlgorithms}

Implementation recommendations for Cookie Algorithms [DNSCOOKIE-IANA]:

Number | Mnemonics          | Client Cookie   | Server Cookie
:------|:-------------------|:----------------|:-------------
1      | SIPHASH24          | MUST            | MUST


[@SipHash-2.4] is a pseudorandom function suitable as message authentication
code, and this document REQUIRES compliant DNS Server to use SipHash24 as a
mandatory and default algorithm for DNS Cookies to ensure interoperability
between the DNS Implementations. The Server Secret MUST be optionally
configurable to make sure that servers in an anycast network return consistent
results. Additional algorithms might be added in the future.

# IANA Considerations

IANA is requested to create and maintain a sub-registry (the "DNS Cookie
Algorithm" registry) of the "Domain Name System (DNS) Parameters"
registry.  The initial values for this registry are described in (#cookieAlgorithms).
This registry operates under the IANA rules for "Expert Review"
registration.

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

# Acknowledgements

Thanks to Witold Krecicki and Pieter Lexis for valuable input, suggestions and
text and above all for implementing a prototype of an interoperable DNS Cookie
in Bind9, Knot and PowerDNS during the hackathon of IETF104 in Prague.  Thanks
for valuable input and suggestions go to Ralph Dolmans, Bob Harold, Daniel
Salzman, ...
