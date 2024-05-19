#!/bin/bash
# Not using `set -e` to avoid exiting immediately when a command fails.
# Not using `set -o pipefail` to avoid pipeline errors causing exits.

cd /var/task/templates

echo "Running pdflatex first pass..."

pdflatex example_template.tex || echo "Warning: pdflatex first pass failed"

echo "Running bibtex..."
bibtex example_template || echo "Warning: bibtex failed"

echo "Running pdflatex second pass..."
pdflatex example_template.tex || echo "Warning: pdflatex second pass failed"

echo "Running pdflatex third pass..."
pdflatex example_template.tex || echo "Warning: pdflatex third pass failed"

