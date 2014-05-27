# This is the Makefile for compiling the gdal and proj4 code needed for 
# SpeciesGeoCoder to run properly.
# Default installation directory is /usr/local/bin. You can change the 
# installation directory by changing the value of the variable "PREFIX".

PWD="."
ROOTDIR=$(PWD)
#DIR=$(shell basename $(PWD))
DIR=$(shell basename $PWD)
PREFIX=/usr/local/bin/test
INSTALLDIR=SpeciesGeoCoder.v.1.0
PROJ4DIR=$(PWD)/src/proj-4.9.0
#GDALDIR=$(PWD)/src/gdal-1.10.1
GDALDIR=./src/gdal-1.10.1
PROJ4_ROOT=$(PROJ4DIR)/install_proj
OS := $(shell uname)
cygwin=$
INSTALL=/usr/bin/install -S

all: install_proj proj4 gdal $(OS)

proj4: install_proj 
	cd $(PROJ4DIR) && ./configure --prefix=$(PROJ4DIR)/install_proj
	make -C $(PROJ4DIR)
	make install -C $(PROJ4DIR)

gdal: $(OS)_configure
	make -C $(GDALDIR)

Linux_configure: Darwin_configure
Darwin_configure:
	cd $(GDALDIR) && ./configure --disable-shared --with-static-proj4=$(PROJ4_ROOT)

CYGWIN_NT-5.1_configure: CYGWIN_NT-6.1_configure
CYGWIN_NT-6.1-WOW64_configure: CYGWIN_NT-6.1_configure
CYGWIN_NT-6.1_configure:
	cd $(GDALDIR) && ./configure --with-static-proj4=$(PROJ4_ROOT)

Darwin:
	@cp $(GDALDIR)/apps/gdalinfo $(ROOTDIR)/bin/gdalinfo_darwin
	@cp $(GDALDIR)/apps/gdallocationinfo $(ROOTDIR)/bin/gdallocationinfo_darwin

Linux:
	@cp $(GDALDIR)/apps/gdalinfo $(ROOTDIR)/bin/gdalinfo_linux
	@cp $(GDALDIR)/apps/gdallocationinfo $(ROOTDIR)/bin/gdallocationinfo_linux

CYGWIN_NT-5.1: CYGWIN_NT-6.1
CYGWIN_NT-6.1-WOW64: CYGWIN_NT-6.1
CYGWIN_NT-6.1:
	@ln -s $(GDALDIR)/apps/gdalinfo.exe $(ROOTDIR)/bin/gdalinfo_cygwin
	@ln -s $(GDALDIR)/apps/gdallocationinfo.exe $(ROOTDIR)/bin/gdallocationinfo_cygwin

install_proj:
	-mkdir $(PROJ4DIR)/install_proj

install: $(OS)
	@echo "Installing SpeciesGeoCoder in $(PREFIX)"
	@cp -R $(PWD) $(PREFIX)/$(INSTALLDIR)
	@$(INSTALL) speciesgeocoder $(PREFIX)
	@echo "#!/bin/bash  \npython $(PREFIX)/$(INSTALLDIR)/geocoder.py \$$*" > $(PREFIX)/speciesgeocoder

uninstall:
	@echo "Removing SpeciesGeoCoder from $(PREFIX)"
	@-rm $(PREFIX)/speciesgeocoder
	@-rm -r $(PREFIX)/$(INSTALLDIR)

clean:
	make clean -C $(PROJ4DIR)
	make clean -C $(GDALDIR)

distclean:
	make distclean -C $(PROJ4DIR)
	make distclean -C $(GDALDIR)
