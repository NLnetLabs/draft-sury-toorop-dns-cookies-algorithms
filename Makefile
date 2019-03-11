DOCNAME = draft-sury-toorop-dns-cookies-algorithms-00

$(DOCNAME).txt: $(DOCNAME).xml
	xml2rfc --text $<

$(DOCNAME).xml: $(DOCNAME).md
	sed 's/@DOCNAME@/$(DOCNAME)/g' $< | mmark --xml2 --page > $@

clean:
	rm -f $(DOCNAME).txt $(DOCNAME).xml
