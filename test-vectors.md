# Test vectors

## Learning a new Server Cookie

A resolver (client) sending from IPv4 address 198.51.100.100, sends a query for
`example.com` to an authoritiative server listening on 192.0.2.53 from
which it has not yet learned the server cookie.

The DNS requests and replies shown in this Appendix, are in a "dig" like format.
The content of the DNS COOKIE Option is shown in hexadecimal format after
`; COOKIE: `.

~~~ ascii-art
;; Sending:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 57406
;; flags:; QUERY: 1, ANSWER: 0, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: a05862bf552bbd22
;; QUESTION SECTION:
;example.com.                IN      A

;; QUERY SIZE: 52
~~~

The authoritative nameserver (server) is configured with the following secret:
e5e973e5a6b2a43f48e7dc849e37bfcf (as hex data).

It receives the query at Wed Jun  5 10:53:05 UTC 2019.

The content of the DNS COOKIE Option that the server will return is shown
below in hexadecimal format after `; COOKIE: `

~~~ ascii-art
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 57406
;; flags: qr aa; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: a05862bf552bbd22010000005cf79f11de1bba0952b0ff82 (good)
;; QUESTION SECTION:
;example.com.                IN      A

;; ANSWER SECTION:
example.com.         86400   IN      A       192.0.2.34

;; Query time: 6 msec
;; SERVER: 192.0.2.53#53(192.0.2.53)
;; WHEN: Wed Jun  5 10:53:05 UTC 2019
;; MSD SIZE  rcvd: 84
~~~
## The same client learning a renewed (fresh) Server Cookie

40 minutes later, the same resolver (client) queries the same server for
for `example.org` :

~~~ ascii-art
;; Sending:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 50939
;; flags:; QUERY: 1, ANSWER: 0, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: a05862bf552bbd22010000005cf79f11de1bba0952b0ff82
;; QUESTION SECTION:
;example.org.                IN      A

;; QUERY SIZE: 52
~~~

The authoritative nameserver (server) now generates a new Server Cookie.
The server SHOULD do this because it can see the Server Cookie send by the
client is older than half an hour (#timestampField), but it is also fine for
a server to generate a new Server Cookie sooner, or even for every answer.

~~~ ascii-art
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 50939
;; flags: qr aa; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: a05862bf552bbd22010000005cf7a87144c909a80f560a7f (good)
;; QUESTION SECTION:
;example.org.                IN      A

;; ANSWER SECTION:
example.org.         86400   IN      A       192.0.2.34

;; Query time: 6 msec
;; SERVER: 192.0.2.53#53(192.0.2.53)
;; WHEN: Wed Jun  5 11:33:05 UTC 2019
;; MSD SIZE  rcvd: 84
~~~
## Another client learning a renewed Server Cookie

Another resolver (client) with IPv4 address 198.51.100.100 sends a request to
the same server with a valid Server Cookie that it learned before
(at Wed Jun  5 09:46:25 UTC 2019). Note that the Server Cookie has Reserved bytes set,
but is still valid with the configured secret; the Hash part is calculated
taking along the Reserved bytes.

~~~ ascii-art
;; Sending:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 34736
;; flags:; QUERY: 1, ANSWER: 0, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: 35fe2405c6e35ce201abcdef5cf78f71f36da1fa58a43879
;; QUESTION SECTION:
;example.com.                IN      A

;; QUERY SIZE: 52
~~~

The authoritative nameserver (server) replies with a freshly generated Server
Cookie for this client conformant with this specification; so with the Reserved
bits set to zero.

~~~ ascii-art
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 34736
;; flags: qr aa; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: 35fe2405c6e35ce2010000005cf7a9ac70f66429813e466a (good)
;; QUESTION SECTION:
;example.com.                IN      A

;; ANSWER SECTION:
example.com.         86400   IN      A       192.0.2.34

;; Query time: 6 msec
;; SERVER: 192.0.2.53#53(192.0.2.53)
;; WHEN: Wed Jun  5 11:38:20 UTC 2019
;; MSD SIZE  rcvd: 84
~~~
## IPv6 query with rolled over secret

The query below is from a client with IPv6 address 2001:db8:220:1:59de:d0f4:8769:82b8 to a server
with IPv6 address 2001:db8:8f::53.  The client has learned a valid Server Cookie
before when the Server had secret: dd3bdf9344b678b185a6f5cb60fca715.  The server now uses a
new secret, but it can still validate the Server Cookie provided by the client
as the old secret has not expired yet.

~~~ ascii-art
;; Sending:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 6774
;; flags:; QUERY: 1, ANSWER: 0, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: fedba308ab9fddb2010000005cf7c579bbc73b7d5da18dd1
;; QUESTION SECTION:
;example.net.                IN      A

;; QUERY SIZE: 52
~~~

The authoritative nameserver (server) replies with a freshly generated server
cookie for this client with its new secret: 445536bcd2513298075a5d379663c962

~~~ ascii-art
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 6774
;; flags: qr aa; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: fedba308ab9fddb2010000005cf7c609449d89428c0e2d92 (good)
;; QUESTION SECTION:
;example.net.                IN      A

;; ANSWER SECTION:
example.net.         86400   IN      A       192.0.2.34

;; Query time: 6 msec
;; SERVER: 2001:db8:8f::53#53(2001:db8:8f::53)
;; WHEN: Wed Jun  5 13:36:57 UTC 2019
;; MSD SIZE  rcvd: 84
~~~

