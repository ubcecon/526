ECON526 := /home/paul/526/ECON526
OUTDIR := $(ECON526)/lectures/paul
SRCDIR := ./site
QMDFILES := $(shell find $(SRCDIR) -type f -name '*.qmd')
HTMLFILES := $(patsubst $(SRCDIR)%,$(OUTDIR)%,$(QMDFILES:.qmd=.html))

QMDWITHCODE := $(shell grep -rl '```{python}' $(QMDFILES))
NOTEBOOKS := $(patsubst $(SRCDIR)%,$(OUTDIR)%,$(QMDWITHCODE:.qmd=.ipynb))

VENVTOUCH := $(SRCDIR)/.venv/touchfile

venv: $(VENVTOUCH)

$(SRCDIR)/.venv/touchfile: $(SRCDIR)/pyproject.toml
	cd $(SRCDIR); uv sync
	touch $(VENVTOUCH)

html: $(HTMLFILES) data

notebooks: $(NOTEBOOKS) data

all: html notebooks

$(OUTDIR)/%.ipynb: $(SRCDIR)/%.qmd
	source $(SRCDIR)/.venv/bin/activate; quarto render $< --profile lectures --to ipynb --no-clean

.PHONY: venv html notebooks all check-uncommitted deploy

$(OUTDIR)/%.html: $(SRCDIR)/%.qmd $(SRCDIR)/_quarto.yml $(SRCDIR)/styles.css
	source $(SRCDIR)/.venv/bin/activate; quarto render $<

check-uncommitted:
	@if [ -n "$$(git status --porcelain)" ]; then \
		echo "Warning: This repository has uncommitted changes."; \
		read -p "Continue? [y/N] " ans; \
		case "$$ans" in \
			[yY]|[yY][eE][sS]) ;; \
			*) echo "Aborting deploy."; exit 1 ;; \
		esac; \
	fi

deploy: check-uncommitted all
	MSG=$$(git log -1 --pretty=%B); \
	cd $(OUTDIR) || exit 1; git add *; git commit -a -m "Update to Paul's slides: $$MSG"; git push origin main_2025
#commit -a -m "Automated updates to slides."; git push origin main_2024

data: site/data/learning_mindset.csv \
	site/data/billboard_impact.csv \
	site/data/cigar.csv

site/data/learning_mindset.csv:
	wget -O $@ "https://raw.githubusercontent.com/matheusfacure/python-causality-handbook/master/causal-inference-for-the-brave-and-true/data/learning_mindset.csv"

site/data/billboard_impact.csv:
	wget -O $@ "https://raw.githubusercontent.com/matheusfacure/python-causality-handbook/master/causal-inference-for-the-brave-and-true/data/billboard_impact.csv"

site/data/smoking.csv:
	wget -O $@ "https://raw.githubusercontent.com/matheusfacure/python-causality-handbook/master/causal-inference-for-the-brave-and-true/data/smoking.csv"
