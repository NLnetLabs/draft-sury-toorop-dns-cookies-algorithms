#!/bin/sh

TESTPATH=`dirname $0`
[ ! -x "${TESTPATH}/client-cookie" ] && >&2 echo "client-cookie program missing" && exit 1
[ ! -x "${TESTPATH}/server-cookie" ] && >&2 echo "server-cookie program missing" && exit 1

CLIENT_IP1=198.51.100.100
SERVER_IP=192.0.2.53
CLIENT_SECRET1=3f6651c981c1d73e587925d2f9985f08
SERVER_SECRET=e5e973e5a6b2a43f48e7dc849e37bfcf
CLIENT_COOKIE1=`${TESTPATH}/client-cookie ${SERVER_IP} ${CLIENT_SECRET1}`
QUERY_ID1=57406
QUERY_NAME1=example.com
QUERY_TIME1=1559731985
QUERY_TIME1_STR=`LC_ALL=C TZ=UTC date -d @${QUERY_TIME1}`
QUERY_TIME1_RFC=`LC_ALL=C TZ=UTC date -d @${QUERY_TIME1} --rfc-3339=seconds`
SERVER_COOKIE1=`${TESTPATH}/server-cookie ${CLIENT_COOKIE1} ${CLIENT_IP1} ${SERVER_SECRET} ${QUERY_TIME1}`

cat << EOT
# Test vectors {#testVectors}

## Learning a new Server Cookie

A resolver (client) sending from IPv4 address ${CLIENT_IP1}, sends a query for
\`${QUERY_NAME1}\` to an authoritative server listening on ${SERVER_IP} from
which it has not yet learned the server cookie.

The DNS requests and replies shown in this Appendix, are in a "dig" like format.
The content of the DNS COOKIE Option is shown in hexadecimal format after
\`; COOKIE: \`.

~~~ ascii-art
;; Sending:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: ${QUERY_ID1}
;; flags:; QUERY: 1, ANSWER: 0, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: ${CLIENT_COOKIE1}
;; QUESTION SECTION:
;${QUERY_NAME1}.                IN      A

;; QUERY SIZE: 52
~~~

The authoritative nameserver (server) is configured with the following secret:
${SERVER_SECRET} (as hex data).

It receives the query at ${QUERY_TIME1_STR}.

The content of the DNS COOKIE Option that the server will return is shown
below in hexadecimal format after \`; COOKIE: \`.

The Timestamp field (#timestampField) in the returned Server Cookie has value 
${QUERY_TIME1}. In [@!RFC3339] format this is ${QUERY_TIME1_RFC}.

~~~ ascii-art
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: ${QUERY_ID1}
;; flags: qr aa; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: ${SERVER_COOKIE1} (good)
;; QUESTION SECTION:
;${QUERY_NAME1}.                IN      A

;; ANSWER SECTION:
${QUERY_NAME1}.         86400   IN      A       192.0.2.34

;; Query time: 6 msec
;; SERVER: ${SERVER_IP}#53(${SERVER_IP})
;; WHEN: ${QUERY_TIME1_STR}
;; MSD SIZE  rcvd: 84
~~~
EOT

QUERY_ID2=50939
QUERY_NAME2=example.org
QUERY_TIME2=`expr ${QUERY_TIME1} + 2400`
QUERY_TIME2_STR=`LC_ALL=C TZ=UTC date -d @${QUERY_TIME2}`
QUERY_TIME2_RFC=`LC_ALL=C TZ=UTC date -d @${QUERY_TIME2} --rfc-3339=seconds`
SERVER_COOKIE2=`${TESTPATH}/server-cookie ${CLIENT_COOKIE1} ${CLIENT_IP1} ${SERVER_SECRET} ${QUERY_TIME2}`

cat << EOT
## The same client learning a renewed (fresh) Server Cookie

40 minutes later, the same resolver (client) queries the same server for
\`${QUERY_NAME2}\`. It reuses the Server Cookie it learned in the previous
query.

The Timestamp field in that previously learned Server Cookie, which is now send
along in the request, was and is ${QUERY_TIME1}. In [@!RFC3339] format this is
${QUERY_TIME1_RFC}.

~~~ ascii-art
;; Sending:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: ${QUERY_ID2}
;; flags:; QUERY: 1, ANSWER: 0, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: ${SERVER_COOKIE1}
;; QUESTION SECTION:
;${QUERY_NAME2}.                IN      A

;; QUERY SIZE: 52
~~~

The authoritative nameserver (server) now generates a new Server Cookie.
The server SHOULD do this because it can see the Server Cookie send by the
client is older than half an hour (#timestampField), but it is also fine for
a server to generate a new Server Cookie sooner, or even for every answer.

The Timestamp field in the returned new Server Cookie has value ${QUERY_TIME2},
which in [@!RFC3339] format is ${QUERY_TIME2_RFC}.

~~~ ascii-art
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: ${QUERY_ID2}
;; flags: qr aa; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: ${SERVER_COOKIE2} (good)
;; QUESTION SECTION:
;${QUERY_NAME2}.                IN      A

;; ANSWER SECTION:
${QUERY_NAME2}.         86400   IN      A       192.0.2.34

;; Query time: 6 msec
;; SERVER: ${SERVER_IP}#53(${SERVER_IP})
;; WHEN: ${QUERY_TIME2_STR}
;; MSD SIZE  rcvd: 84
~~~
EOT

CLIENT_IP2=203.0.113.203
CLIENT_SECRET2=4c311517fab6bfe2e149ab74ec1bc9a0
CLIENT_COOKIE2=`${TESTPATH}/client-cookie ${SERVER_IP} ${CLIENT_SECRET2}`
QUERY_TIME3=`expr ${QUERY_TIME1} - 4000`
QUERY_TIME3_STR=`LC_ALL=C TZ=UTC date -d @${QUERY_TIME3}`
QUERY_TIME3_RFC=`LC_ALL=C TZ=UTC date -d @${QUERY_TIME3} --rfc-3339=seconds`
SERVER_COOKIE3=`${TESTPATH}/server-cookie ${CLIENT_COOKIE2} ${CLIENT_IP2} ${SERVER_SECRET} ${QUERY_TIME3} abcdef`
QUERY_ID3=34736
QUERY_TIME4=`expr ${QUERY_TIME2} + 315`
QUERY_TIME4_STR=`LC_ALL=C TZ=UTC date -d @${QUERY_TIME4}`
QUERY_TIME4_RFC=`LC_ALL=C TZ=UTC date -d @${QUERY_TIME4} --rfc-3339=seconds`
SERVER_COOKIE4=`${TESTPATH}/server-cookie ${CLIENT_COOKIE2} ${CLIENT_IP2} ${SERVER_SECRET} ${QUERY_TIME4}`

cat << EOT
## Another client learning a renewed Server Cookie

Another resolver (client) with IPv4 address ${CLIENT_IP2} sends a request to
the same server with a valid Server Cookie that it learned before
(at ${QUERY_TIME3_STR}).

The Timestamp field in Server Cookie in the request has value ${QUERY_TIME3},
which in [@!RFC3339] format is ${QUERY_TIME3_RFC}.

Note that the Server Cookie has Reserved bytes set, but is still valid with the
configured secret; the Hash part is calculated taking along the Reserved bytes.

~~~ ascii-art
;; Sending:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: ${QUERY_ID3}
;; flags:; QUERY: 1, ANSWER: 0, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: ${SERVER_COOKIE3}
;; QUESTION SECTION:
;${QUERY_NAME1}.                IN      A

;; QUERY SIZE: 52
~~~

The authoritative nameserver (server) replies with a freshly generated Server
Cookie for this client conformant with this specification; so with the Reserved
bits set to zero.

The Timestamp field in the returned new Server Cookie has value ${QUERY_TIME4},
which in [@!RFC3339] format is ${QUERY_TIME4_RFC}.

~~~ ascii-art
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: ${QUERY_ID3}
;; flags: qr aa; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: ${SERVER_COOKIE4} (good)
;; QUESTION SECTION:
;${QUERY_NAME1}.                IN      A

;; ANSWER SECTION:
${QUERY_NAME1}.         86400   IN      A       192.0.2.34

;; Query time: 6 msec
;; SERVER: ${SERVER_IP}#53(${SERVER_IP})
;; WHEN: ${QUERY_TIME4_STR}
;; MSD SIZE  rcvd: 84
~~~
EOT

CLIENT_IP6="2001:db8:220:1:59de:d0f4:8769:82b8"
SERVER_IP6="2001:db8:8f::53"
CLIENT_SECRET6=3b495ba6a5b7fd87735bd58f1ef7261d
CLIENT_COOKIE6=`${TESTPATH}/client-cookie ${SERVER_IP6} ${CLIENT_SECRET6}`
SERVER_SECRET6=dd3bdf9344b678b185a6f5cb60fca715
QUERY_TIME6=1559741817
QUERY_TIME6_STR=`LC_ALL=C TZ=UTC date -d @${QUERY_TIME6}`
QUERY_TIME6_RFC=`LC_ALL=C TZ=UTC date -d @${QUERY_TIME6} --rfc-3339=seconds`

SERVER_COOKIE6=`${TESTPATH}/server-cookie ${CLIENT_COOKIE6} ${CLIENT_IP6} ${SERVER_SECRET6} ${QUERY_TIME6}`
QUERY_ID6=6774
QUERY_NAME6=example.net
SERVER_SECRET7=445536bcd2513298075a5d379663c962
QUERY_TIME7=1559741961
QUERY_TIME7_STR=`LC_ALL=C TZ=UTC date -d @${QUERY_TIME7}`
QUERY_TIME7_RFC=`LC_ALL=C TZ=UTC date -d @${QUERY_TIME7} --rfc-3339=seconds`
SERVER_COOKIE7=`${TESTPATH}/server-cookie ${CLIENT_COOKIE6} ${CLIENT_IP6} ${SERVER_SECRET7} ${QUERY_TIME7}`

cat << EOT
## IPv6 query with rolled over secret

The query below is from a client with IPv6 address ${CLIENT_IP6} to a server
with IPv6 address ${SERVER_IP6}.  The client has learned a valid Server Cookie
before (at ${QUERY_TIME6_STR}) when the Server had the secret:
${SERVER_SECRET6}.  The server now uses a new secret, but it can still validate
the Server Cookie provided by the client as the old secret has not expired yet.

The Timestamp field in the Server Cookie in the request has value
${QUERY_TIME6}, which in [@!RFC3339] format is ${QUERY_TIME6_RFC}.

~~~ ascii-art
;; Sending:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: ${QUERY_ID6}
;; flags:; QUERY: 1, ANSWER: 0, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: ${SERVER_COOKIE6}
;; QUESTION SECTION:
;${QUERY_NAME6}.                IN      A

;; QUERY SIZE: 52
~~~

The authoritative nameserver (server) replies with a freshly generated server
cookie for this client with its new secret: ${SERVER_SECRET7}

The Timestamp field in the returned new Server Cookie has value
${QUERY_TIME7}, which in [@!RFC3339] format is ${QUERY_TIME7_RFC}.

~~~ ascii-art
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: ${QUERY_ID6}
;; flags: qr aa; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: ${SERVER_COOKIE7} (good)
;; QUESTION SECTION:
;${QUERY_NAME6}.                IN      A

;; ANSWER SECTION:
${QUERY_NAME6}.         86400   IN      A       192.0.2.34

;; Query time: 6 msec
;; SERVER: ${SERVER_IP6}#53(${SERVER_IP6})
;; WHEN: ${QUERY_TIME6_STR}
;; MSD SIZE  rcvd: 84
~~~

EOT
