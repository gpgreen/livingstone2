all: test

TESTDIRS = 1 2 3 4 5 6 7 10 11

.PHONY: test clean

test:
	for dir in $(TESTDIRS) ; do \
		(cd $$dir ; ./dotest) || exit 1 ; \
	done

clean:
	find . -name '*~' -exec rm {} \;
	rm -f */.ior
