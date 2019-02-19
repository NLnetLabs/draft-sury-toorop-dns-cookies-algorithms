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
value = "draft-toorop-dnsop-rfc7873bis-00"
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

Operational practice with DNS Cookies [@!RFC7873] has shown it to be
problematic in Multi-vendor anycast networks.  To address, all the
(potentially multi-vendor) DNS server software in such an environment
needs to be aligned on how to precisely create server cookies.  This
document provides precise directions for creating server cookies and
also operator guidelines for DNS Cookies deployments on multi-vendor
anycast networks.  Furthermore, [@!FNV] is obsoleted as an algorithm
for calculating server cookies and replaced with [@!SipHash-2.4] as a
required to implement algorithm.

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

# Constructing a Client Cookie {#clientCookie}

...

# Constructing a Server Cookie {#serverCookie}

...

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


