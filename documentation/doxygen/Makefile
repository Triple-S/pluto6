
.PHONY: filter folders mathjax js images doxygen replaceCollaborationDiagrams

OS=$(shell uname)
ifeq ($(OS), Darwin)
   export DOXYGEN_LDD := otool -L
   NJOB ?= $(shell sysctl -n hw.ncpu)
else
   export DOXYGEN_LDD := ldd
   NJOB ?= $(shell nproc)
endif

Python3_EXECUTABLE ?= python3
export Python3_EXECUTABLE
export PYSPARK_PYTHON := $(Python3_EXECUTABLE)

export ROOT_SOURCE_DIRECTORY := $(shell readlink -e /opt/root/root-default-source)

DOXYGEN_OUTPUT_DIRECTORY ?= $(shell readlink -e /opt/pluto/pluto-default-doc)
export DOXYGEN_OUTPUT_DIRECTORY
export DOXYGEN_SOURCE_DIRECTORY := $(shell readlink -e /opt/pluto/pluto-default-source)
export DOXYGEN_PLUTO_VERSION := $(shell cd $(DOXYGEN_OUTPUT_DIRECTORY); pwd -P | cut -f 2 -d '-')
export DOXYGEN_EXAMPLE_PATH := $(DOXYGEN_OUTPUT_DIRECTORY)/macros
export DOXYGEN_IMAGE_PATH := $(DOXYGEN_OUTPUT_DIRECTORY)/html
export DOXYGEN_NOTEBOOK_PATH := $(DOXYGEN_OUTPUT_DIRECTORY)/notebooks
export DOXYGEN_STRIP_PATH := $(DOXYGEN_SOURCE_DIRECTORY)
export DOXYGEN_INCLUDE_PATH := $(shell find -L $(DOXYGEN_SOURCE_DIRECTORY) -maxdepth 2 -type d)
export DOXYGEN_PYZDOC_PATH := $(DOXYGEN_OUTPUT_DIRECTORY)/pyzdoc

PYZ_DIR = $(ROOT_SOURCE_DIRECTORY)/bindings/pyroot/pythonizations/python/ROOT/_pythonization

define MkDir
    +@[ -d $1 ] || mkdir -p $1
endef

all: filter folders mathjax js images doxygen replaceCollaborationDiagrams notebooks rootWork

filter:
	`root-config --cxx` -o filter filter.cxx -std=c++14 -O2

mathjax:
	$(call MkDir,$(DOXYGEN_IMAGE_PATH))
	tar xfz $(ROOT_SOURCE_DIRECTORY)/documentation/doxygen/mathjax.tar.gz -C $(DOXYGEN_IMAGE_PATH)

js:
	$(call MkDir,$(DOXYGEN_IMAGE_PATH))
	cp -r $(ROOT_SOURCE_DIRECTORY)/js $(DOXYGEN_IMAGE_PATH)

images:
	$(call MkDir,$(DOXYGEN_IMAGE_PATH))
	@if [ $(shell find images | wc -l) -gt 1 ]; then cp images/* $(DOXYGEN_IMAGE_PATH); fi

pyzdoc:
	$(call MkDir,$(DOXYGEN_PYZDOC_PATH))
	$(Python3_EXECUTABLE) $(ROOT_SOURCE_DIRECTORY)/documentation/doxygen/extract_docstrings.py $(PYZ_DIR) $(DOXYGEN_PYZDOC_PATH)
	$(Python3_EXECUTABLE) $(ROOT_SOURCE_DIRECTORY)/documentation/doxygen/print_roofit_pyz_doctrings.py > $(DOXYGEN_PYZDOC_PATH)/_roofit.pyzdoc

doxygen: filter pyzdoc
	rm -f tutorialWorklist_py tutorialWorklist_root
	$(call MkDir,$(DOXYGEN_OUTPUT_DIRECTORY))
	$(call MkDir,$(DOXYGEN_EXAMPLE_PATH))
	$(call MkDir,$(DOXYGEN_NOTEBOOK_PATH))
	./createPlutoModulesDocs.sh
	doxygen
	rm -rf files c1* *.ps *.eps *.png *.jpg *.tex *.svg *.pdf *.root *.xpm *.out *.dat *.dtd *.dot *.txt *.csv *.log *.rs
	rm -rf listofclass.sh tmva* data* result* config* test* Roo* My* Freq*
	rm -f Doxyfile_INPUT filter MDF.C pca.C
	rm -f greek.gif hsumanim.gif mathsymb.gif parallelcoordtrans.gif
	rm -rf files c1* *.ps *.png *.svg *.pdf *.root *.xpm *.out *.dat *.dtd *.dot *.txt listofclass.sh

collaborationDiagrams:
	bash ./makeCollaborationDiagrams.sh

replaceCollaborationDiagrams: doxygen collaborationDiagrams
	bash $(ROOT_SOURCE_DIRECTORY)/documentation/doxygen/modifyClassWebpages.sh -j$(NJOB)

tutorialWorklist_py: doxygen
tutorialWorklist_root: doxygen

notebooks: tutorialWorklist_py makeNotebooks.sh
	cp $(ROOT_SOURCE_DIRECTORY)/tutorials/unfold/*.xml $(ROOT_SOURCE_DIRECTORY)/tutorials/unfold/*.dtd $(DOXYGEN_NOTEBOOK_PATH)/
	bash ./makeNotebooks.sh $< -j$(NJOB)
	rm -f $(DOXYGEN_NOTEBOOK_PATH)/*.root

rootWork: tutorialWorklist_root
	xargs -L 1 -P 12 root < $<

clean:
	@if [ $(shell find $(DOXYGEN_OUTPUT_DIRECTORY) | wc -l) -gt 1 ]; then rm -r $(DOXYGEN_OUTPUT_DIRECTORY)/*; fi
	@if [ $(shell find -maxdepth 1 | grep dataset | wc -l) -gt 1 ]; then rm dataset*; fi
	@if [ -f filter ]; then rm filter; fi
	rm -rf tutorialWorklist_py tutorialWorklist_root
