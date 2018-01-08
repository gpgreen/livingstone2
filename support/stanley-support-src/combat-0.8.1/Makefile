#
# This Makefile is primarily used to generate the distribution files
# directly from the CVS repository.
#

all:
	chmod +x bin/idl2tcl bin/iordump
	chmod +x demo/*/server.tcl
	chmod +x demo/*/client.tcl
	chmod +x demo/random/random
	chmod +x test/*/dotest
	chmod +x test/*/server.tcl

#
# To make files for distribution from CVS:
#
# make <dist> VERSION=\"<version>\" CVSTAG=\"<tag>\"
#  where:
#   <dist>    is tgz or zip, or "dist" for both
#   <version> is the file's version suffix
#   <tag>     is the CVS tag or date, e.g., \"-D now\"
#

.SUFFIXES:
.PHONY: dist tgz zip co

VERSION = current
CVSTAG = -D now
TGZDIST = gorilla-$(VERSION).tar.gz
ZIPDIST = gorilla-$(VERSION).zip

dist: tgz zip
tgz: $(TGZDIST)
zip: $(ZIPDIST)

$(TGZDIST): co
	(cd co ; tar cf ../combat-$(VERSION).tar combat-$(VERSION))
	gzip -9 combat-$(VERSION).tar

$(ZIPDIST): co
	(cd co/combat-$(VERSION) ; zip -r ../../combat-$(VERSION).zip *)

co:
	rm -rf co
	mkdir co
	(cd co ; cvs export $(CVSTAG) -d combat-$(VERSION) combat)
	$(MAKE) -C co/combat-$(VERSION)/doc
	rm -rf co/combat-$(VERSION)/C++ co/combat-$(VERSION)/idl2tcl-win32
	chmod +x co/combat-$(VERSION)/bin/idl2tcl co/combat-$(VERSION)/bin/iordump
	chmod +x co/combat-$(VERSION)/demo/*/server.tcl
	chmod +x co/combat-$(VERSION)/demo/*/client.tcl
	chmod +x co/combat-$(VERSION)/demo/random/random
	chmod +x co/combat-$(VERSION)/test/*/dotest
	chmod +x co/combat-$(VERSION)/test/*/server.tcl

clean:
	$(MAKE) -C test clean
	$(MAKE) -C bin clean
	rm -f demo/*/server.ior
	find . -name '*~' -exec rm {} \;
	rm -rf co

distclean: clean
	$(MAKE) -C bin distclean
