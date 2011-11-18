### generic GNU make Makefile for .tex -> .pdf.
### ransford at cs.umass.edu
### http://github.com/ransford/pdflatex-makefile

## Name of the target file, minus .pdf: e.g., TARGET=mypaper causes this
## Makefile to turn mypaper.tex into mypaper.pdf
TARGET = report

## If $(TARGET).tex refers to .bib files like \bibliography{foo,bar}, then
## $(BIBFILES) will contain foo.bib and bar.bib, and both files will be added as
## dependencies to the $(TARGET).pdf target.
## Effect: updating a .bib file will trigger re-typesetting.
BIBFILES = $(patsubst %,%.bib,\
  $(shell grep '\\bibliography{' $(TARGET).tex | \
          sed -e 's/^.*\\bibliography{//' -e 's/}//' -e 's/, */ /g'))

## If $(TARGET).tex refers to other .tex files like \input{foo} and
## \input{bar}, then $(INCLUDEDTEX) will contain foo.tex and bar.tex, and both
## files will be added as dependencies to the $(TARGET).pdf target.
## Effect: updating an \input'ed .tex file will trigger re-typesetting.
INCLUDEDTEX = $(patsubst %,%.tex,\
		$(shell grep '\\input{' $(TARGET).tex | \
			sed -e 's/^\\input{\([^}]*\)}.*/\1/'))

PDFLATEX = pdflatex
BIBTEX = bibtex

## Action for 'make view'.  'open -a Preview' works on Mac OS X.
PDFVIEWER = open -a Preview

# .PHONY names all targets that aren't filenames
.PHONY: all clean pdf view foo

all: pdf

clean:
	rm -f $(TARGET).aux $(TARGET).log $(TARGET).out \
		$(TARGET).pdf $(TARGET).blg $(TARGET).bbl

pdf: $(TARGET).pdf

view: $(TARGET).pdf
	$(PDFVIEWER) $(TARGET).pdf

%.pdf: %.tex $(INCLUDEDTEX) $(BIBFILES)
	$(PDFLATEX) $*
ifneq ($(strip $(BIBFILES)),)
	@if grep -q "undefined references" $*.log; then \
		$(BIBTEX) $* && $(PDFLATEX) $*; fi
endif
	@while grep -q "Rerun to" $*.log; do \
		$(PDFLATEX) $*; done
