MASTER=master
AUX_DIR=aux
TEX_DIR=tex
PDF_DIR=pdf

define run_pdflatex
  pdflatex -halt-on-error -shell-escape -output-directory $(AUX_DIR) $< > /dev/null
endef

all: $(TEX_DIR)/$(MASTER).tex
	$(call run_pdflatex)
	$(call run_pdflatex)
	-@mv $(AUX_DIR)/$(MASTER).pdf $(PDF_DIR)
