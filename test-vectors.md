# Test vectors {#testVectors}

## Learning a new Server Cookie

A resolver (client) sending from IPv4 address 198.51.100.100, sends a query for
`example.com` to an authoritative server listening on 192.0.2.53 from
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
; COOKIE: 2464c4abcf10c957
;; QUESTION SECTION:
;example.com.                IN      A

;; QUERY SIZE: 52
~~~

The authoritative nameserver (server) is configured with the following secret:
e5e973e5a6b2a43f48e7dc849e37bfcf (as hex data).

It receives the query at Wed Jun  5 10:53:05 UTC 2019.

The content of the DNS COOKIE Option that the server will return is shown
below in hexadecimal format after `; COOKIE: `.

The Timestamp field (#timestampField) in the returned Server Cookie has value 
1559731985. In [@!RFC3339] format this is 2019-06-05 10:53:05+00:00.

~~~ ascii-art
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 57406
;; flags: qr aa; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: 2464c4abcf10c957010000005cf79f111f8130c3eee29480 (good)
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
`example.org`. It reuses the Server Cookie it learned in the previous
query.

The Timestamp field in that previously learned Server Cookie, which is now send
along in the request, was and is 1559731985. In [@!RFC3339] format this is
2019-06-05 10:53:05+00:00.

~~~ ascii-art
;; Sending:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 50939
;; flags:; QUERY: 1, ANSWER: 0, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: 2464c4abcf10c957010000005cf79f111f8130c3eee29480
;; QUESTION SECTION:
;example.org.                IN      A

;; QUERY SIZE: 52
~~~

The authoritative nameserver (server) now generates a new Server Cookie.
The server SHOULD do this because it can see the Server Cookie send by the
client is older than half an hour (#timestampField), but it is also fine for
a server to generate a new Server Cookie sooner, or even for every answer.

The Timestamp field in the returned new Server Cookie has value 1559734385,
which in [@!RFC3339] format is 2019-06-05 11:33:05+00:00.

~~~ ascii-art
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 50939
;; flags: qr aa; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: 2464c4abcf10c957010000005cf7a871d4a564a1442aca77 (good)
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

Another resolver (client) with IPv4 address 203.0.113.203 sends a request to
the same server with a valid Server Cookie that it learned before
(at Wed Jun  5 09:46:25 UTC 2019).

The Timestamp field in Server Cookie in the request has value 1559727985,
which in [@!RFC3339] format is 2019-06-05 09:46:25+00:00.

Note that the Server Cookie has Reserved bytes set, but is still valid with the
configured secret; the Hash part is calculated taking along the Reserved bytes.

~~~ ascii-art
;; Sending:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 34736
;; flags:; QUERY: 1, ANSWER: 0, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: fc93fc62807ddb8601abcdef5cf78f71a314227b6679ebf5
;; QUESTION SECTION:
;example.com.                IN      A

;; QUERY SIZE: 52
~~~

The authoritative nameserver (server) replies with a freshly generated Server
Cookie for this client conformant with this specification; so with the Reserved
bits set to zero.

The Timestamp field in the returned new Server Cookie has value 1559734700,
which in [@!RFC3339] format is 2019-06-05 11:38:20+00:00.

~~~ ascii-art
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 34736
;; flags: qr aa; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: fc93fc62807ddb86010000005cf7a9acf73a7810aca2381e (good)
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
before (at Wed Jun  5 13:36:57 UTC 2019) when the Server had the secret:
dd3bdf9344b678b185a6f5cb60fca715.  The server now uses a new secret, but it can still validate
the Server Cookie provided by the client as the old secret has not expired yet.

The Timestamp field in the Server Cookie in the request has value
1559741817, which in [@!RFC3339] format is 2019-06-05 13:36:57+00:00.

~~~ ascii-art
;; Sending:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 6774
;; flags:; QUERY: 1, ANSWER: 0, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: 22681ab97d52c298010000005cf7c57926556bd0934c72f8
;; QUESTION SECTION:
;example.net.                IN      A

;; QUERY SIZE: 52
~~~

The authoritative nameserver (server) replies with a freshly generated server
cookie for this client with its new secret: 445536bcd2513298075a5d379663c962

The Timestamp field in the returned new Server Cookie has value
1559741961, which in [@!RFC3339] format is .

~~~ ascii-art
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 6774
;; flags: qr aa; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: 22681ab97d52c298010000005cf7c609a6bb79d16625507a (good)
;; QUESTION SECTION:
;example.net.                IN      A

;; ANSWER SECTION:
example.net.         86400   IN      A       192.0.2.34

;; Query time: 6 msec
;; SERVER: 2001:db8:8f::53#53(2001:db8:8f::53)
;; WHEN: Wed Jun  5 13:36:57 UTC 2019
;; MSD SIZE  rcvd: 84
~~~

