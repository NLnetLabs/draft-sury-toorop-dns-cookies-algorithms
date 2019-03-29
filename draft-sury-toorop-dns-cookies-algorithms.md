%%%
Title = "Algorithms for Domain Name System (DNS) Cookies construction"
abbrev = "dns-cookies-algorithms"
docname = "@DOCNAME@"
category = "std"
ipr = "trust200902"
area = "Internet"
workgroup = "DNSOP Working Group"
updates = [7873]
date = 2019-03-28T00:00:00Z

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
organization = "Huawei Technologies"
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
the Same Server Secret be used by each DNS server in a set of anycast
servers."  However, how precisely a Server Cookie is calculated from
this Server Secret, is left to the implementation.

This guidance has let to gallimaufry of DNS Cookie implementations,
calculating the Server Cookie in different ways. As a result, DNS Cookies
are impractical to deploy on multi-vendor anycast networks, because even
when all DNS Software would share the same secret, as RECOMMENDED in Section
6 of [@!RFC7873], the Server Cookie constructed by one implementation
cannot be validated by another.

There is no need for DNS client (resolver) Cookies to be interoperable
across different implementations. Each client need only be able to recognize
its own cookies. However, this document does contain recommendations for
constructing Client Cookies in a Client protecting fashion.

## Contents of this document

Section (#changes) summarises the changes to [@!RFC7873]

In Section (#clientCookie) suggestions for constructing a Client
Cookie are given

In Section (#serverCookie) instructions for constructing a Server 
Cookie are given

In Section (#cookieAlgorithms) the different hash functions usable for DNS
Cookie construction are listed.  [@FNV] and HMAC-SHA-256-64 [@!RFC6234] are
obsoleted and [@SipHash-2.4] is introduced as a REQUIRED hash function for
server side DNS Cookie implementations.

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

In its Appendices A.1 and B.1 [@!RFC7873] provides example "simple"
algorithms for computing Client and Server Cookies, respectively.  These
algorithms MUST NOT be used as the cookies produces are too weak when
evaluated against modern security standards.

In its Appendix B.2 [RFC7873] provides an example "more complex" server
algorithm. This algorithm is replaced by the interoperable specification in
Section (#serverCookie) of this document, which MUST be used be Server
Cookie Implementations.

This document has suggestions on Client Cookie construction in Section
(#clientCookie).  The previous example in Appendix A.2 of [@!RFC7873] is NOT
RECOMMENDED.

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
|    Version    |    SecretID   |           Reserved            |
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

## The SecretID Sub-Field

The SecretID Sub-Field is an opaque field that identifies the Secret that
was used to create this Server Cookie. This fields main purpose is to ease
Secret roll-over - an operator can add a new Secret with a new ID to all the
servers so that it can be used to verify Cookies, and only then switch the
Secret used to create cookies.

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

The Timestamp value specify a date and time in the form of a 32-bit unsigned
number of seconds elapsed since 1 January 1970 00:00:00 UTC, ignoring leap
seconds, in network byte order.  All comparisons involving these fields MUST
use "Serial number arithmetic", as defined in [@!RFC1982]

The DNS Server SHOULD generate new Server Cookie at least if the received Server
Cookie from the Client is older than half an hour.

## The Hash Sub-Field {#hashField}

It's important that all the DNS servers use the same algorithm for computing the
Server Cookie.  This document defines the Version 1 of the Server Side algorithm
to be:

~~~ ascii-art
Hash = SipHash2.4(
    Client Cookie | Version | Reserved | Timestamp | Client-IP,
    Server Secret )
~~~

Notice that Client-IP is used for hash generation even though it's not
included in the cookie value itself. Client-IP can be either 4 bytes for
IPv4 or 16 bytes for IPv6.

# Cookie Algorithms {#cookieAlgorithms}

[@SipHash-2.4] is a pseudorandom function suitable as message authentication
code, and this document REQUIRES compliant DNS Server to use SipHash24 as a
mandatory and default algorithm for DNS Cookies to ensure interoperability
between the DNS Implementations. The Server Secret MUST be optionally
configurable to make sure that servers in an anycast network return consistent
results. Additional algorithms might be added in the future.

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

Thanks to Witold Krecicki and Pieter Lexis for valuable input, suggestions
and text and above all for implementing a prototype of an interoperable DNS
Cookie in Bind9, Knot and PowerDNS during the hackathon of IETF104 in
Prague.  Thanks for valuable input and suggestions go to Ralph Dolmans, Bob
Harold, Daniel Salzman, Martin Hoffmann, ...
