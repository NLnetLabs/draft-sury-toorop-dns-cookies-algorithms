VERSION = 00
DOCNAME = draft-sury-toorop-dnsop-server-cookies

all: $(DOCNAME)-$(VERSION).txt $(DOCNAME)-$(VERSION).html

$(DOCNAME)-$(VERSION).txt: $(DOCNAME).xml
	xml2rfc --text -o $@ $<

$(DOCNAME)-$(VERSION).html: $(DOCNAME).xml
	xml2rfc --html -o $@ $<

$(DOCNAME).xml: $(DOCNAME).md test-vectors.md
	sed 's/@DOCNAME@/$(DOCNAME)-$(VERSION)/g' $< | mmark --xml2 --page > $@

test-vectors.md: test-vectors/print-test-vectors.sh
	test-vectors/print-test-vectors.sh > test-vectors.md

clean:
	rm -f $(DOCNAME)-$(VERSION).txt $(DOCNAME).xml
