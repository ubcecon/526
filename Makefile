ECON526 := /home/paul/526/ECON526
OUTDIR := $(ECON526)/lectures/paul
SRCDIR := ./site
QMDFILES := $(shell find $(SRCDIR) -type f -name '*.qmd')
HTMLFILES := $(patsubst $(SRCDIR)%,$(OUTDIR)%,$(QMDFILES:.qmd=.html))

QMDWITHCODE := $(shell grep -rl '```{python}' $(QMDFILES))
NOTEBOOKS := $(patsubst $(SRCDIR)%,$(OUTDIR)%,$(QMDWITHCODE:.qmd=.ipynb))

updaterequire:
	source $(SRCDIR)/.venv/bin/activate; python -m pip freeze > $(SRCDIR)/requirements.txt

VENVTOUCH := $(SRCDIR)/.venv/touchfile

venv: $(VENVTOUCH)

$(SRCDIR)/.venv/touchfile: $(SRCDIR)/requirements.in
	cd $(SRCDIR); test -d .venv || python3 -m venv .venv
	cd $(SRCDIR); source .venv/bin/activate; pip install -Ur requirements.in
	touch $(VENVTOUCH)


html: $(HTMLFILES) data

notebooks: $(NOTEBOOKS) data

all: html notebooks

$(OUTDIR)/%.ipynb: $(SRCDIR)/%.qmd
	source $(SRCDIR)/.venv/bin/activate; quarto render $< --profile lectures --to ipynb --no-clean

$(OUTDIR)/%.html: $(SRCDIR)/%.qmd $(SRCDIR)/_quarto.yml $(SRCDIR)/styles.css
	source $(SRCDIR)/.venv/bin/activate; quarto render $<

deploy: all
	cd $(OUTDIR); git add *; git commit -a -m "Automated updates to slides."; git push origin main_2024
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
