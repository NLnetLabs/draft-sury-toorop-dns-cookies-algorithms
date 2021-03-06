VERSION = 06
DOCNAME = draft-ietf-dnsop-server-cookies

all: $(DOCNAME)-$(VERSION).txt $(DOCNAME)-$(VERSION).html

$(DOCNAME)-$(VERSION).txt: $(DOCNAME).xml
	xml2rfc --text -o $@ $<

$(DOCNAME)-$(VERSION).html: $(DOCNAME).xml
	xml2rfc --html -o $@ $<

$(DOCNAME).xml: $(DOCNAME).md test-vectors.md
	sed   -e 's/@DOCNAME@/$(DOCNAME)-$(VERSION)/g' \
	      -e 's/<t>/@@T@@/g' -e 's/<\/t>/@@t@@/g' $< | mmark \
	| sed -e 's/@@T@@/<t>/g' -e 's/@@t@@/<\/t>/g' > $@

test-vectors/client-cookie:
	cd test-vectors && make client-cookie

test-vectors/server-cookie:
	cd test-vectors && make server-cookie

test-vectors.md: test-vectors/print-test-vectors.sh test-vectors/client-cookie test-vectors/server-cookie
	test-vectors/print-test-vectors.sh > test-vectors.md

clean:
	rm -f $(DOCNAME)-$(VERSION).txt $(DOCNAME).xml
