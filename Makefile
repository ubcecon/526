ECON526 := /home/paul/526/ECON526
OUTDIR := $(ECON526)/paul
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
	cd $(SRCDIR); test -d venv || python3 -m venv venv
	cd $(SRCDIR); source env/bin/activate; pip install -Ur requirements.txt
	touch $(VENVTOUCH)

all: $(HTMLFILES) $(NOTEBOOKS) venv

$(OUTDIR)/%.ipynb: $(SRCDIR)/%.qmd $(VENVTOUCH)
	source $(SRCDIR)/env/bin/activate; quarto render $< --profile lectures --to ipynb --no-clean

$(OUTDIR)/%.html: $(SRCDIR)/%.qmd $(VENVTOUCH) $(SRCDIR)/_quarto.yml $(SRCDIR)/styles.css
	source $(SRCDIR)/env/bin/activate; quarto render $<

deploy: all
	cd $(ECON526); git commit -a -m "updates to slides"; git push origin main
