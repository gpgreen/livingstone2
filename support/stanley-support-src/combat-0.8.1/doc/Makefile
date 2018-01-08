all: combat.pdf

LYX = /cygdrive/c/Program\ Files/LyX16/bin/lyx.exe

combat.pdf: combat.lyx
	$(LYX) -e pdf2 $^

clean:
	-rm -f *~

distclean: clean
