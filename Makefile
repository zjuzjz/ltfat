## Copyright 2015-2016 Carnë Draug
## Copyright 2015-2016 Oliver Heimlich
## Copyright 2015-2016 Zdeněk Průša
##
## Copying and distribution of this file, with or without modification,
## are permitted in any medium without royalty provided the copyright
## notice and this notice are preserved.  This file is offered as-is,
## without any warranty.

## This makefile requires 
##	 python 2.x
##   javac
##   mat2doc https://github.com/ltfat/mat2doc
##   bibtex2html https://github.com/backtracking/bibtex2html
##


## Note the use of ':=' (immediate set) and not just '=' (lazy set).
## http://stackoverflow.com/a/448939/1609556
PACKAGE := ltfat
VERSION := $(shell cat "ltfat_version")

## This are the files that will be created for the releases.
TARGET_DIR      := ~/publish/target
MAT2DOC         := $(TARGET_DIR)/mat2doc/mat2doc.py
RELEASE_DIR     := $(TARGET_DIR)/$(PACKAGE)-$(VERSION)
RELEASE_TARBALL := $(TARGET_DIR)/$(PACKAGE)-$(VERSION).tar.gz
HTML_DIR        := $(TARGET_DIR)/$(PACKAGE)-html
HTML_TARBALL    := $(TARGET_DIR)/$(PACKAGE)-html.tar.gz

## Remove if not needed, most packages do not have PKG_ADD directives.
# M_SOURCES   := $(wildcard inst/*.m)
# CC_SOURCES  := $(wildcard src/*.cc)
# PKG_ADD     := $(shell grep -sPho '(?<=(//|\#\#) PKG_ADD: ).*' \
#                          $(CC_SOURCES) $(M_SOURCES))

## These can be set by environment variables which allow to easily
## test with different Octave versions.
OCTAVE    ?= octave
MKOCTFILE ?= mkoctfile

HAS_BIBTEX2HTML := $(shell which bibtex2html)
HAS_JAVAC := $(shell which javac)

ifndef HAS_BIBTEX2HTML
	$(error "Please install bibtex2html. E.g. sudo apt-get install bibtex2html")
endif
ifndef HAS_JAVAC
$(error "Please install javac. E.g. sudo apt-get install openjdk-X-jdk, where X is at least 6")
endif


## Targets that are not filenames.
## https://www.gnu.org/software/make/manual/html_node/Phony-Targets.html
.PHONY: help dist html release install all check run clean 

## make will display the command before runnning them.  Use @command
## to not display it (makes specially sense for echo).
help:
	@echo "Targets:"
	@echo "   dist    - Create $(RELEASE_TARBALL) for release"
	@echo "   html    - Create $(HTML_TARBALL) for release"
	@echo "   release - Create both of the above and show md5sums"
	@echo
	@echo "   install - Install the package in GNU Octave"
	@echo "   all     - Build all oct files"
	@echo "   check   - Execute package tests (w/o install)"
	@echo "   doctest - Tests only the help text via the doctest package"
	@echo "   run     - Run Octave with development in PATH (no install)"
	@echo
	@echo "   clean   - Remove releases, html documentation, and oct files"

$(MAT2DOC):
	git clone -b notestargets https://github.com/ltfat/mat2doc $(TARGET_DIR)/mat2doc

## dist and html targets are only PHONY/alias targets to the release
## and html tarballs.
dist: $(RELEASE_TARBALL)
html: $(HTML_TARBALL)

## An implicit rule with a recipe to build the tarballs correctly.
$(RELEASE_TARBALL): $(MAT2DOC)
	@echo "About to start generating release tarball into $(RELEASE_DIR)"
	@python2 $(MAT2DOC) . mat --script=release_keep_tests.py --octpkg --unix --outputdir=$(RELEASE_DIR)
	mv $(RELEASE_DIR)/ltfat-files/$(PACKAGE)-$(VERSION).tar.gz $(RELEASE_TARBALL)

$(HTML_TARBALL): $(HTML_DIR)
	( cd $(TARGET_DIR) ; \
	tar -cvf $(PACKAGE)-html.tar.gz $(PACKAGE)-html ; )

## install is a prerequesite to the html directory (note that the html
## tarball will use the implicit rule for ".tar.gz" files).
$(HTML_DIR): install
	$(RM) -r "$@"
	$(OCTAVE) --no-window-system --silent \
	  --eval "pkg load generate_html; " \
	  --eval "pkg load $(PACKAGE);" \
	  --eval 'generate_package_html ("${PACKAGE}", "$@", "octave-forge");'
	chmod -R a+rX,u+w,go-w $@

## To make a release, build the distribution and html tarballs.
release: dist html
	md5sum $(RELEASE_TARBALL) $(HTML_TARBALL) > $(RELEASE_DIR).md5
	@echo "Upload @ https://sourceforge.net/p/octave/package-releases/new/"
	@echo "    and inform to rebuild release with commit hash '$$(git rev-parse --short HEAD)'"
	@echo 'Execute: git tag -l "of-v${VERSION}"'

install: $(RELEASE_TARBALL)
	@echo "Installing package locally ..."
	$(OCTAVE) --eval 'pkg ("install", "-verbose", "$(RELEASE_TARBALL)")'

# This will not clean all older builds.
# To make a stronger clean you could replace with
# $(RM) -r $(TARGET_DIR)
# But be careful, TARGET_DIR will be deleted!
# That is, be careful what you set in that variable
clean:
	@echo "Cleaning ..."
	$(RM) -r $(RELEASE_DIR) $(RELEASE_TARBALL) $(HTML_TARBALL) $(HTML_DIR) $(TARGET_DIR)/*.md5

##
## Recipes for testing purposes
##

## Build any requires oct files.  Some packages may not need this at all.
## Other packages may require a configure file to be created and run first.
all: $(CC_SOURCES)
	$(MAKE) -C src/

## Start an Octave session with the package directories on the path for
## interactice test of development sources.
run: all
	$(OCTAVE) --persist --path "inst/" --path "src/" \
	  --eval 'if(!isempty("$(DEPENDS)")); pkg load $(DEPENDS); endif;' \
	  --eval '$(PKG_ADD)'

## Test example blocks in the documentation.  Needs doctest package
##  https://octave.sourceforge.io/doctest/index.html
doctest: all
	$(OCTAVE) --path "inst/" --path "src/" \
	  --eval '${PKG_ADD}' \
	  --eval 'pkg load doctest;' \
	  --eval "targets = '$(shell (ls inst; ls src | grep .oct) | cut -f2 -d@ | cut -f1 -d.)';" \
	  --eval "targets = strsplit (targets, ' ');" \
	  --eval "doctest (targets);"

## Note "doctest" as prerequesite.  When testing the package, also check
## the documentation.
check: all doctest
	$(OCTAVE) --path "inst/" --path "src/" \
	  --eval 'if(!isempty("$(DEPENDS)")); pkg load $(DEPENDS); endif;' \
	  --eval '${PKG_ADD}' \
	  --eval 'cellfun(@runtests, {"inst", "src"});'
	  #--eval '__run_test_suite__ ({"inst", "src"}, {});'
