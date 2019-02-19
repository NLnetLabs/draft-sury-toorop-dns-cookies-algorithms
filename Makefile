DOCNAME = draft-sury-dnsop-rfc7873bis-00

$(DOCNAME).txt: $(DOCNAME).xml
	xml2rfc --text $<

$(DOCNAME).xml: $(DOCNAME).md
	sed 's/@DOCNAME@/$(DOCNAME)/g' $< | mmark --xml2 --page > $@

clean:
	rm -f $(DOCNAME).txt $(DOCNAME).xml
