%%%
Title = "Multi-vendor Domain Name System (DNS) Cookies"
abbrev = "rfc7873bis"
docname = "@DOCNAME@"
category = "std"
ipr = "trust200902"
area = "Internet"
workgroup = "DNSOP Working Group"
updates = [7873]
date = 2018-03-01T00:00:00Z

[seriesInfo]
name = "Internet-Draft"
value = "draft-sury-dnsop-rfc7873bis-00"
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

This document provides precise directions for creating Server Cookies
to address this issue.  It also provides operator guidelines for DNS
Cookies deployments on multi-vendor anycast networks.  Furthermore,
[@!FNV] is obsoleted as a suitable Message Authentication Code
function for calculating DNS Cookies. [@!SipHash-2.4] is introduced as
a new REQUIRED MAC function for calculating DNS Cookies.

This document updates [@!RFC7873]


{mainmatter}

# Introduction

Section 6. [@!RFC7873] RECOMMENDs **for simplicity** that the Same
Server Secret be used by each DNS server in a set of anycast servers.
However, how precisely a Server Cookie is calculated from this Server
Secret, is left to the implementation.  Two different example
implementations are given in Appendix B.1. and Appendix B.2.  In the
last implementation example it is suggested that the Server Cookie is
a convenient container for various information at the discretion of
the DNS server (implementer).

This guidance has resulted in different DNS Cookie implementations,
all calculating the Server Cookie in different ways.  That in turn has
caused problems with anycast deployments with DNS Software from
multiple different vendors, because even when all DNS Software would
share the same secret, as RECOMMENDED in Section 6. of [@!RFC7873],
they all produce different Server Cookies based on that secret
and (at least) the Client Cookie and Client IP Address.

## Contents of this document

In Section (#recommendation), we expand the recommendation in Section
6. of [@!RFC7873], that in a set of anycast servers on only the same
Server Secret should be shared, but also the same method to calculate
the Server Cookie from the Server Secret.

In Section (#clientCookie) instructions for constructing a Client
Cookie are given

In Section (#serverCookie) instructions for constructing a Server 
Cookie are given

In Section (#MACfunctions) the different MAC functions to be used for
constructing the Server Cookie are given.  [@!FNV] is obsoleted and
[@!SipHash-2.4] is introduced as a REQUIRED MAC function for DNS Cookie
implementations.

## Definitions

The key words "**MUST**", "**MUST NOT**", "**REQUIRED**", 
"**SHALL**", "**SHALL NOT**", "**SHOULD**", "**SHOULD NOT**",
"**RECOMMENDED**", "**NOT RECOMMENDED**", "**MAY**", and
"**OPTIONAL**" in this document are to be interpreted as described in
BCP 14 [@!RFC2119] [@!RFC8174] when, and only when, they appear in all
capitals, as shown here.


# Recommendation for DNS Cookie use with multi-vendor anycast
# deployments {#recommendation}

...

# Cookie Algorithms {#cookieAlgorithms}

Implementation recommendations for Cookie Algorithms [DNSCOOKIE-IANA]:

   +--------+--------------------+-----------------+---------------+
   | Number | Mnemonics          | Client Cookie   | Server Cookie |
   +--------+--------------------+-----------------+---------------+
   | 1      | FNV                | MUST NOT        | MUST NOT      |  
   | 2      | HMAC-SHA-256-64    | MUST NOT        | MUST NOT      |  
   | 3      | AES                | MAY             | MAY           |  
   | 4      | SIPHASH24          | MUST            | MUST          |  
   +--------+--------------------+-----------------+---------------+

FNV is a Non-Cryptographic Hash Algorithm and this document obsoletes
the usage of FNV in DNS Cookies.

HMAC-SHA-256-64 is an HMAC-SHA-256 algorithm reduced to 64-bit.  This particular
algorithm was implemented in BIND, but it was never the default algorithm and the
computational costs makes it unsuitable to be used in DNS Cookies.  Therefore
this document obsoleted the usage of HMAC-SHA-256 algorithm in the DNS Cookies.

The AES algorithm has been the default DNS Cookies algorithm in BIND until
version x.y.z, and other implementations MAY implement AES algorithm as
implemented in BIND for backwards compatibility.  However it's recommended that
new implementations implement only a pseudorandom functions for DNS Cookies, in
this document that would be SipHash24.

[@!SipHash-2.4] is a pseudorandom function suitable as message authentication
code, and this document REQUIRES compliant DNS Server to use SipHash24 as a
mandatory and default algorithm for DNS Cookies to ensure interoperability
between the DNS Implementations.

# Constructing a Client Cookie {#clientCookie}

The Client Cookie is a nonce and should be treated as such.  For simplicity,
it can be calculated from Client IP Address, Server IP Address and a secret
known only to the Client.  The Client Cookie SHOULD have at least 64-bits
of entropy.  If a secure pseudorandom function (like SipHash24) is used there's
no need to change Client secret periodically and change the Client secret only
if it has been compromised.

It's recommended but not required that a pseudorandom function is used to
construct the Client Cookie:

  Client-Cookie =
    MAC_Algorithm( Client IP Address | Server IP Address,
	               Client Secret )

where "|" indicates concatenation.

# Constructing a Server Cookie {#serverCookie}

The Server Cookie is effectively message authentication code (MAC) and should be
treated as such.

The Server Cookie is not required to be changed periodically if a secure
pseudorandom function is used.  This 

The 128-bit Server Cookie consists of:

 Sub-field       Size
-------------  --------
 Version        8 bits
 Cookie Algo    8 bits
 Reserved      16 bits
 Timestamp     32 bits
 Hash          64 bits

The Timestamp value prevents Replay Attacks and MUST be checked by the server to
be within a defined period of time.  The DNS Server SHOULD allow Cookies within
1 hour period in the past and 5 minutes into the future to allow operation of
low volume clients and certain time skew between the DNS servers in the anycast.

The DNS Server SHOULD generate new Server Cookie at least if the received Server
Cookie from the Client is older than half an hour.

It's important that all the DNS servers use the same algorithm for computing the
Server Cookie.  This document defines the Version 1 of the Server Side algorithm
to be:

  Hash =
    Cookie_Algorithm( Client Cookie | Version | Hash Algo | Reserved | TimeStamp,
	                  Server Secret )

# Message Authentication Code functions for DNS Cookies {#MACfunctions}


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


