#!/usr/bin/env make -f

PREFIX=/usr/local
IDENTIFIER=org.targetdisk.RDeeM

VERSION ?= 2.5

PACKAGE_BUILD = $(shell which pkgbuild)
#ARCH_FLAGS=-arch x86_64 -arch arm64

.PHONY: build

RDeeM.app: SetResX Resources Info.plist monitor.icns
	mkdir -p RDeeM.app/Contents/MacOS/
	cp SetResX RDeeM.app/Contents/MacOS/
	cp -r Info.plist Resources RDeeM.app/Contents
	rm RDeeM.app/Contents/Resources/Icon_512x512.png
	rm RDeeM.app/Contents/Resources/StatusIcon_sel.png
	rm RDeeM.app/Contents/Resources/StatusIcon_sel@2x.png
	mv monitor.icns RDeeM.app/Contents/Resources


SetResX: main.o SRApplicationDelegate.o ResMenuItem.o cmdline.o utils.o
	$(CC) $^ -o $@ $(ARCH_FLAGS) -framework CoreGraphics -framework Foundation -framework ApplicationServices -framework AppKit


clean:
	rm -f SetResX
	rm -f *.o
	rm -f *icns
	rm -rf RDeeM.app
	rm -rf dmgroot dmgroot.pkg pkgroot
	rm -f *.pkg *.dmg

%.o: %.mm
	$(CC) $(CPPFLAGS) $(CFLAGS) $(ARCH_FLAGS) $< -c -o $@


%.icns: %.png
	sips -s format icns $< --out $@

pkg: RDeeM.app
	mkdir -p pkgroot/Applications
	cp -rv $< pkgroot/Applications/
	$(PACKAGE_BUILD) --root pkgroot/  --identifier $(IDENTIFIER) \
		--version $(VERSION) "RDeeM-$(VERSION).pkg"
	rm -f RDeeM.pkg
	ln -s RDeeM-$(VERSION).pkg RDeeM.pkg

pkgdmg: pkg
	mkdir -p dmgroot.pkg
	cp RDeeM-$(VERSION).pkg dmgroot.pkg/
	rm -f RDeeM-installer-$(VERSION).dmg
	hdiutil makehybrid -hfs -hfs-volume-name "RDeeM $(VERSION) Installer" \
		-o "RDeeM-installer-$(VERSION).dmg" dmgroot.pkg/
	rm -f RDeeM-installer.dmg
	ln -s RDeeM-installer--$(VERSION).dmg RDeeM-installer.dmg

dmg: RDeeM.app
	mkdir -p dmgroot
	cp -rv $< dmgroot
	rm -f RDeeM-$(VERSION).dmg
	hdiutil makehybrid -hfs -hfs-volume-name "RDeeM $(VERSION)" \
		-o "RDeeM-$(VERSION).dmg" dmgroot/
	rm -f RDeeM.dmg
	ln -s RDeeM-$(VERSION).dmg RDeeM.dmg

all: dmg pkg pkgdmg

.PHONY: pkg dmg build clean all
