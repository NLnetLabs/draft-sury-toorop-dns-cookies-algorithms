%%%
Title = "Interoperable Domain Name System (DNS) Server Cookies"
abbrev = "server-cookies"
docname = "@DOCNAME@"
category = "std"
ipr = "trust200902"
area = "Internet"
workgroup = "DNSOP Working Group"
updates = [7873]
date = 2021-01-14T00:00:00Z

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

DNS Cookies, as specified in [@!RFC7873], are a lightweight DNS transaction
security mechanism that provide limited protection to DNS servers and
clients against a variety of amplification denial of service, forgery,
or cache poisoning attacks by off-path attackers.

This document updates [@!RFC7873] with precise directions for creating Server
Cookies so that an anycast server set including diverse implementations will
interoperate with standard clients, suggestions for constructing Client Cookies
in a privacy preserving fashion, and suggestions on how to update a Server
Secret.  An IANA registry listing the methods and associated pseudo random
function suitable for creating DNS Server Cookies is created, with the method
described in this document as the first and as of yet only entry.

{mainmatter}

# Introduction

DNS Cookies, as specified in [@!RFC7873], are a lightweight DNS transaction
security mechanism that provide limited protection to DNS servers and clients
against a variety of denial of service amplification, forgery, or cache
poisoning attacks by off-path attackers. This document specifies a means of
producing interoperable Cookies so that an anycast server set including diverse
implementations can be easily configured to interoperate with standard clients.
Also single implementation or non-anycast services can benefit from a
well-studied standardized algorithm for which the behavioural and security
characteristics are more widely known.

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
constructing Client Cookies in a client protecting fashion.

## Terminology and Definitions

The key words "**MUST**", "**MUST NOT**", "**REQUIRED**",
"**SHALL**", "**SHALL NOT**", "**SHOULD**", "**SHOULD NOT**",
"**RECOMMENDED**", "**NOT RECOMMENDED**", "**MAY**", and
"**OPTIONAL**" in this document are to be interpreted as described in
BCP 14 [@!RFC2119] [@!RFC8174] when, and only when, they appear in all
capitals, as shown here.

* "IP address" is used herein as a length independent term covering
   both IPv4 and IPv6 addresses.

# Changes to [RFC7873] {#changes}

In its Appendices A.1 and B.1, [@!RFC7873] provides example "simple" algorithms
for computing Client and Server Cookies, respectively.  These algorithms MUST
NOT be used as the resulting cookies are too weak when evaluated against modern
security standards.

In its Appendix B.2, [@!RFC7873] provides an example "more complex" server
algorithm. This algorithm is replaced by the interoperable specification in
(#serverCookie) of this document, which MUST be used by Server Cookie
implementations.

This document has suggestions on Client Cookie construction in (#clientCookie).
The previous example in Appendix A.2 of [@!RFC7873] is NOT RECOMMENDED.

# Constructing a Client Cookie {#clientCookie}

The Client Cookie acts as an identifier for a given client and its IP address,
and needs to be unguessable. In order to provide minimal authentication of the
targeted server, a client MUST use a different Client Cookie for each different
Server IP address. This complicates a server's ability to spoof answers for
other DNS servers. The Client Cookie SHOULD have 64-bits of entropy.

When a server does not support DNS Cookies, the client MUST NOT send the same
Client Cookie to that same server again. Instead, it is recommended that the
client does not send a Client Cookie to that server for a certain period,
for example five minutes, before it retries with a new Client Cookie.

When a server does support DNS Cookies, the client should store the Client
Cookie alongside the Server Cookie it registered for that server.

Except for when the Client IP address changes, there is no need to change the
Client Cookie often. It is reasonable to change the Client Cookie then only if
it has been compromised or after a relatively long implementation-defined
period of time.  The time period should be no longer than a year, and in any
case Client Cookies are not expected to survive a program restart.

~~~ ascii-art
Client-Cookie = 64 bits of entropy
~~~

Previously, the recommended algorithm to compute the Client Cookie included
Client IP address as an input to a hashing function. However, when implementing
the DNS Cookies, several DNS vendors found impractical to include the Client IP
as the Client Cookie is typically computed before the Client IP address is
known. Therefore, the requirement to put Client IP address as input was
removed.

However, for privacy reasons, in order to prevent tracking of devices across
links and to not circumvent IPv6 Privacy Extensions [@RFC4941], clients MUST
NOT re-use a Client or Server Cookie after the Client IP address has changed.

One way to satisfy this requirement for non-re-use is to register the Client IP
address alongside the Server Cookie when it receives the Server Cookie.  In
subsequent queries to the server with that Server Cookie, the socket MUST be
bound to the Client IP address that was also used (and registered) when it
received the Server Cookie.  Failure to bind MUST then result in a new Client
Cookie.

# Constructing a Server Cookie {#serverCookie}

The Server Cookie is effectively a Message Authentication Code (MAC). The
Server Cookie, when it occurs in a COOKIE option in a request, is intended to
weakly assure the server that the request came from a client that is both at
the source IP address of the request and using the Client Cookie included in
the option.  This assurance is provided by the Server Cookie that the server
(or any other server from the anycast set) sent to that client in an earlier
response appearing as the Server Cookie field in the request (see Section 5.2
of [@!RFC7873]).

DNS Cookies do not provide protection against "on-path" adversaries (see
Section 9 of [@!RFC7873]). An on path observer that has seen a Server Cookie
for a client, can abuse that Server Cookie to spoof request for that client
within the timespan a Server Cookie is valid (see (#timestampField)).

The Server Cookie is calculated from the Client Cookie, a series of Sub-Fields
specified below, the Client IP address, and a Server Secret known only to the
server, or servers responding on the same address in an anycast set.

For calculation of the Server Cookie, a pseudorandom function is RECOMMENDED
with the property that an attacker that does not know the Server Secret, cannot
find (any information about) the Server Secret and cannot create a Server
Cookie for any combination of - the Client Cookie, the  series of Sub-Fields
specified below and the client IP address - for which it has not seen a Server
Cookie before. Because DNS servers need to recalculate it in order to verify
Server Cookies, it is RECOMMENDED for the pseudorandom function to be
performant. The [@!SipHash-2-4] pseudorandom function introduced in
(#hashField) fit these recommendations.

Changing the Server Secret regularly is RECOMMENDED but, when a secure
pseudorandom function is used, it need not be changed too frequently.  For
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

The value of the Reserved Sub-Field is reserved for future versions of server
side Cookie construction.  On construction it MUST be set to zero octets.  On
Server Cookie verification the server MUST NOT enforce those fields to be zero
and the Hash should be computed with the received value as described in
(#hashField).

## The Timestamp Sub-Field {#timestampField}

The Timestamp value prevents Replay Attacks and MUST be checked by the server
to be within a defined period of time.  The DNS server SHOULD allow Cookies
within 1 hour period in the past and 5 minutes into the future to allow
operation of low volume clients and some limited time skew between the DNS
servers in the anycast set.

The Timestamp value specifies a date and time in the form of a 32-bit
**unsigned** number of seconds elapsed since 1 January 1970 00:00:00 UTC,
ignoring leap seconds, in network byte order.  All comparisons involving these
fields MUST use "Serial number arithmetic", as defined in [@!RFC1982]. The
[@!RFC1982] specifies how the differences should be handled. This handles any
relative time window less than 68 years, at any time in the future (2038 or
2106 or 2256 or 22209 or later.)

The DNS server SHOULD generate a new Server Cookie at least if the received
Server Cookie from the client is more than half an hour old, but MAY
generate a new cookie more often than that.

## The Hash Sub-Field {#hashField}

It's important that all the DNS servers use the same algorithm for computing
the Server Cookie.  This document defines the Version 1 of the server side
algorithm to be:

~~~ ascii-art
Hash = SipHash-2-4(
    Client Cookie | Version | Reserved | Timestamp | Client-IP,
    Server Secret )
~~~

where "|" indicates concatenation.

Notice that Client-IP is used for hash generation even though it is not
included in the cookie value itself. Client-IP can be either 4 bytes for IPv4
or 16 bytes for IPv6. The length of all the concatenated elements (the input
into [@!SipHash-2-4]) MUST be either precisely 20 bytes in case of an IPv4
Client-IP or precisely 32 bytes in case of an IPv6 Client-IP.

When a DNS server receives a Server Cookie version 1 for validation, the length
of the received COOKIE option MUST be precisely 24 bytes: 8 bytes for the
Client Cookie plus 16 bytes for the Server Cookie. Verification of the length
of the received COOKIE option is REQUIRED to guarantee the length of the input
into [@!SipHash-2-4] to be precisely 20 bytes in case of an IPv4 Client-IP and
precisely 32 bytes in case of an IPv6 Client-IP. This ensures that the input
into [@!SipHash-2-4] is an injective function of the elements making up the
input, and thereby prevents data substitution attacks.  More specifically, this
prevents a 36 byte COOKIE option coming from an IPv4 Client-IP to be validated
as if it were coming from an IPv6 Client-IP.

The Server Secret MUST be configurable to make sure that servers in an anycast
network return consistent results.

# Updating the Server Secret {#rollingSecret}

Changing the Server Secret regularly is RECOMMENDED.  All servers in an anycast
set must be able to verify the Server Cookies constructed by all other servers
in that anycast set at all times.  Therefore it is vital that the Server Secret
is shared among all servers before it is used to generate Server Cookies on any
server.

Also, to maximize maintaining established relationships between clients and
servers, an old Server Secret should be valid for verification purposes for a
specific period.

To facilitate this, deployment of a new Server Secret MUST be done in three
stages:

Stage 1
: <t><br>The new Server Secret is deployed on all the servers in an anycast set by
  the operator.</t>
  <t>Each server learns the new Server Secret, but keeps using the previous Server
  Secret to generate Server Cookies.</t>
  <t>Server Cookies constructed with the both the new Server Secret and with
  the previous Server Secret are considered valid when verifying.</t>
  <t>After stage 1 completed, all the servers in the anycast set have learned the
  new Server Secret, and can verify Server Cookies constructed with it, but keep
  generating Server Cookies with the old Server Secret.</t>

Stage 2
: <t><br>This stage is initiated by the operator after the Server Cookie is present
  on all members in the anycast set.</t>
  <t>When entering Stage 2, servers start generating Server Cookies with the new
  Server Secret. The previous Server Secret is not yet removed/forgotten about.</t>
  <t>Server Cookies constructed with the both the new Server Secret and with
  the previous Server Secret are considered valid when verifying.</t>

Stage 3
: <t><br>This stage is initiated by the operator when it can be assumed that most
  clients have obtained a Server Cookie derived from the new Server Secret.</t>
  <t>With this stage, the previous Server Secret can be removed and MUST NOT be
  used anymore for verifying.</t>
  <t>We RECOMMEND the operator to wait at least a period to be the longest TTL in
  the zones served by the server plus 1 hour after it initiated Stage 2,
  before initiating Stage 3.</t>
  <t>The operator SHOULD wait at least longer than the period clients are allowed
  to use the same Server Cookie, which SHOULD be 1 hour, see (#timestampField).</t>

# Cookie Algorithms {#cookieAlgorithms}

[@!SipHash-2-4] is a pseudorandom function suitable as Message Authentication
Code.  This document REQUIRES compliant DNS server to use SipHash-2-4 as a
mandatory and default algorithm for DNS Cookies to ensure interoperability
between the DNS Implementations.

The construction method and pseudorandom function used in calculating and
verifying the Server Cookies are determined by the initial version byte and by
the length of the Server Cookie. Additional pseudorandom or construction
algorithms for Server Cookies might be added in the future.

# IANA Considerations {#ianaConsiderations}

IANA is requested to create a registry on the "Domain Name System (DNS) Parameters"
IANA web page as follows:

Registry Name: DNS Server Cookie Methods<br>
Assignment Policy: Expert Review<br>
Reference: [this document], [@!RFC7873]<br>
Note: Server Cookie method (construction and pseudorandom algorithm) are
determined by the Version in the first byte of the Cookie and by the Cookie
size. Server Cookie size is limited to the inclusive range of 8 to 32 bytes.

Version | Size  | Method
-------:|------:|:--------------------
0       |  8-32 | reserved
1       |  8-15 | unassigned
1       |    16 | SipHash-2-4 \[this document\] (#serverCookie)
1       | 17-32 | unassigned
2-239   |  8-32 | unassigned
240-254 |  8-32 | private use
255     |  8-32 | reserved

# Security and Privacy Considerations {#securityConsiderations}

DNS Cookies provide limited protection to DNS servers and clients against a
variety of denial of service amplification, forgery or cache poisoning attacks
by off-path attackers. They provide no protection against on-path adversaries
that can observe the plaintext DNS traffic. An on-path adversary that can
observe a Server Cookie for a client and server interaction, can use that
Server Cookie for denial of service amplification, forgery or cache poisoning
attacks directed at that client for the lifetime of the Server Cookie.

## Client Cookie construction

In [@!RFC7873] it was RECOMMENDED to construct a Client Cookie by using a
pseudorandom function of the Client IP address, the Server IP address, and a
secret quantity known only to the client. The Client IP address was included to
ensure that a client could not be tracked if its IP address changes due to
privacy mechanisms or otherwise.

In this document, we changed Client Cookie construction to be just 64 bits of
entropy newly created for each new upstream server the client connects to.
As a consequence additional care needs to be taken to prevent tracking of
clients.  To prevent tracking, a new Client Cookie for a server MUST be created
whenever the Client IP address changes.

Unfortunately, tracking Client IP address changes is impractical with servers
that do not support DNS Cookies. To prevent tracking of clients with non DNS
Cookie supporting servers, a client MUST NOT send a previously sent Client
Cookie to a server not known to support DNS Cookies. To prevent the creation of
a new Client Cookie for each query to an non DNS Cookies supporting server, it
is RECOMMENDED to not send a Client Cookie to that server for a certain period,
for example five minutes.

Summarizing:

  * In order to provide minimal authentication, a client MUST use a
    different Client Cookie for each different Server IP address.

  * To prevent tracking of clients, a new Client Cookie MUST be created
    when the Client IP address changes.

  * To prevent tracking of clients by a non DNS Cookie supporting server,
    a client MUST NOT send a previously sent Client Cookie to a server in the
    absence of an associated Server Cookie.

Note that it is infeasible for a client to detect change of the public IP
address when the client is behind a routing device performing Network Address
Translation (NAT).  A server may track the public IP address of that routing
device performing the NAT. Preventing tracking of the public IP of a NAT
performing routing device is beyond the scope of this document.

## Server Cookie construction

[@!RFC7873] did not give a precise recipe for constructing Server Cookies, but
did recommend usage of a pseudorandom function strong enough to prevent
guessing of cookies. In this document SipHash-2-4 is assigned as the
pseudorandom function to be used for version 1 Server Cookies. SipHash-2-4 is
considered sufficiently strong for the immediate future, but predictions about
future development in cryptography and cryptanalysis are beyond the scope of
this document.

The precise structure of version 1 Server Cookies is defined in this document.
A portion of the structure is made up of unhashed data elements which are
exposed in clear text to an on-path observer. These unhashed data elements are
taken along as input to the SipHash-2-4 function of which the result is the
other portion of the Server Cookie, so the unhashed portion of the Server
Cookie can not by changed by an on-path attacking without also recalculating
the hashed portion for which the Server Secret needs to be known.

One of the elements in the unhashed portion of version 1 Server Cookies is a
Timestamp used to prevent Replay Attacks.  Servers verifying version 1 Server
Cookies need to have access to a reliable time value to compare with the
Timestamp value, that cannot be altered by an attacker. Furthermore, all
servers participating in an anycast set that validate version 1 Server Cookies
need to have their clocks synchronized.

The cleartext Timestamp data element reveal to an on-path adversary using an
observed Server Cookie to attack the client for which the Server Cookie was
constructed (as shown in the first paragraph of this Section), the lifetime the
observed Server Cookie can be used for the attack.

In addition to the Security Considerations in this section, the Security
Considerations section of [@!RFC7873] still apply.

# Acknowledgements {#acknowledgements}

Thanks to Witold Krecicki and Pieter Lexis for valuable input, suggestions and
text and above all for implementing a prototype of an interoperable DNS Cookie
in Bind9, Knot and PowerDNS during the hackathon of IETF104 in Prague.  Thanks
for valuable input and suggestions go to Ralph Dolmans, Bob Harold, Daniel
Salzman, Martin Hoffmann, Mukund Sivaraman, Petr Spacek, Loganaden Velvindron,
Bob Harold, Philip Homburg, Tim Wicinski and Brian Dickson.

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

<reference anchor='SipHash-2-4' target='https://doi.org/10.1007/978-3-642-34931-7_28'>
    <front>
        <title>SipHash: a fast short-input PRF</title>
	<author fullname="Jean-Philippe Aumasson" initials="J." surname="Aumasson" />
	<author fullname="Daniel J. Bernstein" initials="D. J." surname="Bernstein" />
	<date year="2012"/>
    </front>
    <seriesInfo name='Progress in Cryptology - INDOCRYPT 2012.' value='Lecture Notes in Computer Science, vol 7668. Springer.'/>
</reference>

{backmatter}

{{test-vectors.md}}

# Implementation status

At the time of writing, BIND from version 9.16 and Knot DNS from version 2.9.0
create Server Cookies according to the recipe described in this draft. Unbound
and NSD have an Proof of Concept implementation that has been tested for
interoperability during the hackathon at the IETF104 in Prague.  Construction
of privacy maintaining Client Cookies according to the directions in this draft
have been implemented in the getdns library and will be in the upcoming
getdns-1.6.1 release and in Stubby version 0.3.1.
