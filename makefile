.PHONY: all clean realclean

##############################
#         Parameters         #
##############################

PROJECT = thesis

OTHER_FILES = \
    abstract.tex \
	chapters/app.tex \
	chapters/background.tex \
	chapters/implementation.tex \
	chapters/intro.tex \
	chapters/pret.tex \
	chapters/pret_wcet.tex \
	chapters/related.tex \
	chapters/summary.tex;

##############################
#         Variables          #
##############################

AUX_TEXT = \\\\citation\|\\\\bibdata\|\\\\bibstyle

PDF_FILE = $(PROJECT).pdf
AUX_FILE = $(PROJECT).aux
BIB_FILE = $(PROJECT).bib
BBL_FILE = $(PROJECT).bbl
BLG_FILE = $(PROJECT).blg
LOG_FILE = $(PROJECT).log
MD5_FILE = $(AUX_FILE).md5
TEX_FILE = $(PROJECT).tex


##############################
#          Commands          #
##############################

latex = $(RM) -f $(PDF_FILE) && \
	if [ -e $(PDF_FILE) ]; then \
	  echo "$(PDF_FILE) is opened"; \
	  echo "Please close before running latex."; \
	  exit 1; \
	fi && \
	echo Executing LaTeX... && \
	latex -output-format=pdf -halt-on-error $(PROJECT) > latex.log

bibtex = echo Executing BibTeX... && \
	bibtex -terse $(PROJECT) > bibtex.log


##############################
#           Rules            #
##############################

all: $(PDF_FILE) $(AUX_FILE)

$(AUX_FILE): $(TEX_FILE)
	$(latex)

$(BBL_FILE): $(TEX_FILE) $(AUX_FILE) $(BIB_FILE)
	@if [ $(BIB_FILE) -nt $(BBL_FILE) ] \
	      || ! (grep -E $(AUX_TEXT) $(AUX_FILE) | md5 | grep -q `cat $(MD5_FILE)`) \
	      || grep -q "error message" $(BLG_FILE); then \
	  if ! ($(bibtex)); then \
	    exit 1; \
	  fi; \
	  grep -E $(AUX_TEXT) $(AUX_FILE) | md5 > $(MD5_FILE); \
	fi

$(PDF_FILE): $(TEX_FILE) $(BBL_FILE) 
	@rerun=1; \
	count=1; \
	while [ "$$rerun" != "0" ]; do \
	  rerun=0; \
	  if ! (grep -E $(AUX_TEXT) $(AUX_FILE) | md5 | grep -q `cat $(MD5_FILE)`) \
	        || grep -q "error message" $(BLG_FILE); then \
	    if ! ($(bibtex)); then \
	      exit 1; \
	    fi; \
	    grep -E $(AUX_TEXT) $(AUX_FILE) | md5 > $(MD5_FILE); \
	    rerun=1; \
	  elif [ $(LOG_FILE) -nt $(TEX_FILE) ] \
	     && grep -q "Rerun to get" $(LOG_FILE); then \
	    rerun=1; \
	  else \
	    for file in $?; do \
	      if [ "$$rerun" = "0" ] && [ $$file -nt $(PDF_FILE) ] ; then \
		echo "else failed"; \
	        rerun=1; \
	      fi; \
	    done; \
	  fi; \
	  \
	  if [ "$$rerun" != "0" ]; then \
	    if ! (grep -E $(AUX_TEXT) $(AUX_FILE) | md5 | grep -q `cat $(MD5_FILE)`) \
	          && ! ($(MAKE) $(BBL_FILE)); then \
	      exit 1; \
	    fi; \
	    if ! ($(latex)); then \
	      exit 1; \
	    fi; \
	  fi; \
	  let "count=count+1"; \
	  if [ $$count -gt 4 ]; then \
		grep "LaTeX Warning" $(LOG_FILE) | cat; \
		rerun=0; \
	  fi; \
	done
	@if grep -E $(AUX_TEXT) $(AUX_FILE) | md5 | grep -q `cat $(MD5_FILE)`; then \
	  touch $(BBL_FILE); \
	  touch $(PDF_FILE); \
	fi

clean:
	@$(RM) *.md5 *.out *.log *.bbl *.blg *.aux *~ *.bak *.lot *.lof *.toc

realclean: clean
	@$(RM) $(PDF_FILE)
