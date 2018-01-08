SDX = c:/Software/Tclkit/tclkitsh-win32.upx.exe c:/Software/Tclkit/sdx.kit
WINKIT = c:/Software/Tclkit/tclkitsh-win32.upx.exe
LINKIT = c:/Software/Tclkit/tclkitsh-linux-x86.upx.bin
COMBAT = ../orb
TCLKILL = ../tclkill

all: idl2tcl.exe iordump.exe

idl2tcl.exe: idl2tcl.kit
	rm -rf temp
	mkdir temp
	cp $< temp/idl2tcl.kit
	(cd temp; $(SDX) unwrap idl2tcl.kit)
	cp $(WINKIT) temp/tclkit.exe
	(cd temp; $(SDX) wrap idl2tcl.kit -runtime tclkit.exe)
	mv temp/idl2tcl.kit $@
	rm -rf temp

idl2tcl.kit: idl2tcl
	rm -rf temp
	mkdir temp
	cp idl2tcl temp/idl2tcl.tcl
	(cd temp; $(SDX) qwrap idl2tcl.tcl)
	(cd temp; $(SDX) unwrap idl2tcl.kit)
	cp -r $(COMBAT) temp/idl2tcl.vfs/lib/combat
	cp -r $(TCLKILL) temp/idl2tcl.vfs/lib/tclkill
	(cd temp; $(SDX) wrap idl2tcl.kit)
	mv temp/idl2tcl.kit $@
	rm -rf temp

iordump.exe: iordump.kit
	rm -rf temp
	mkdir temp
	cp $< temp/iordump.kit
	(cd temp; $(SDX) unwrap iordump.kit)
	cp $(WINKIT) temp/tclkit.exe
	(cd temp; $(SDX) wrap iordump.kit -runtime tclkit.exe)
	mv temp/iordump.kit $@
	rm -rf temp

iordump.kit: iordump
	rm -rf temp
	mkdir temp
	cp iordump temp/iordump.tcl
	(cd temp; $(SDX) qwrap iordump.tcl)
	(cd temp; $(SDX) unwrap iordump.kit)
	cp -r $(COMBAT) temp/iordump.vfs/lib/combat
	(cd temp; $(SDX) wrap iordump.kit)
	mv temp/iordump.kit $@
	rm -rf temp

distclean: clean
	rm -rf *.exe *.kit *.zip *.tar.gz

clean:
	rm -rf temp core a.out *.ior *~
