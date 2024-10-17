ECON526 := /home/paul/526/ECON526
OUTDIR := $(ECON526)/lectures/paul
SRCDIR := ./site
QMDFILES := $(shell find $(SRCDIR) -type f -name '*.qmd')
HTMLFILES := $(patsubst $(SRCDIR)%,$(OUTDIR)%,$(QMDFILES:.qmd=.html))

QMDWITHCODE := $(shell grep -rl '```{python}' $(QMDFILES))
NOTEBOOKS := $(patsubst $(SRCDIR)%,$(OUTDIR)%,$(QMDWITHCODE:.qmd=.ipynb))

updaterequire:
	source $(SRCDIR)/env/bin/activate; python -m pip freeze > $(SRCDIR)/requirements.txt
VENVTOUCH := $(SRCDIR)/env/touchfile

venv: $(VENVTOUCH)

$(SRCDIR)/env/touchfile: $(SRCDIR)/requirements.txt
	cd $(SRCDIR); test -d venv || python3 -m venv env
	cd $(SRCDIR); source env/bin/activate; pip install -Ur requirements.txt
	touch $(VENVTOUCH)


html: $(HTMLFILES) venv data

notebooks: $(NOTEBOOKS) venv data

all: html notebooks

$(OUTDIR)/%.ipynb: $(SRCDIR)/%.qmd
	source $(SRCDIR)/env/bin/activate; quarto render $< --profile lectures --to ipynb --no-clean

$(OUTDIR)/%.html: $(SRCDIR)/%.qmd $(SRCDIR)/_quarto.yml $(SRCDIR)/styles.css
	source $(SRCDIR)/env/bin/activate; quarto render $<

deploy: all
	cd $(OUTDIR); git add *; git commit -a -m "Automated updates to slides."; git push origin main
	git commit -a -m "Automated updates to slides."; git push origin main

data: site/data/learning_mindset.csv \
	site/data/billboard_impact.csv \
	site/data/cigar.csv

site/data/learning_mindset.csv:
	wget -O $@ "https://raw.githubusercontent.com/matheusfacure/python-causality-handbook/master/causal-inference-for-the-brave-and-true/data/learning_mindset.csv"

site/data/billboard_impact.csv:
	wget -O $@ "https://raw.githubusercontent.com/matheusfacure/python-causality-handbook/master/causal-inference-for-the-brave-and-true/data/billboard_impact.csv"

site/data/smoking.csv:
	wget -O $@ "https://raw.githubusercontent.com/matheusfacure/python-causality-handbook/master/causal-inference-for-the-brave-and-true/data/smoking.csv"
