# Compile the gdal and proj4 code needed for SpeciesGeoCoder to run properly

ROOTDIR=$(PWD)
PROJ4DIR=$(ROOTDIR)/dev/gdal/proj-4.9.0
GDALDIR=$(ROOTDIR)/dev/gdal/gdal*
PROJ4_ROOT=$(PROJ4DIR)/install_proj
OS := $(shell uname)



all: install_proj proj4 gdal $(OS)

proj4: install_proj
	cd $(PROJ4DIR) && ./configure --prefix=$(PROJ4DIR)/install_proj
	make -C $(PROJ4DIR)
	make install -C $(PROJ4DIR)

gdal:
	cd $(GDALDIR) && ./configure --disable-shared --with-static-proj4=$(PROJ4_ROOT)
	make -C $(GDALDIR)

Darwin:
	cp $(GDALDIR)/apps/gdalinfo $(ROOTDIR)/bin/gdalinfo_darwin
	cp $(GDALDIR)/apps/gdallocationinfo $(ROOTDIR)/bin/gdallocationinfo_darwin

Linux:
	cp $(GDALDIR)/apps/gdalinfo $(ROOTDIR)/bin/gdalinfo_linux
	cp $(GDALDIR)/apps/gdallocationinfo $(ROOTDIR)/bin/gdallocationinfo_linux


install_proj:
	-mkdir $(PROJ4DIR)/install_proj

clean:
	make clean -C $(PROJ4DIR)
	make clean -C $(GDALDIR)

distclean:
	make distclean -C $(PROJ4DIR)

