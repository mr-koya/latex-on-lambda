#!/bin/bash
# Not using `set -e` to avoid exiting immediately when a command fails.
# Not using `set -o pipefail` to avoid pipeline errors causing exits.

pwd

echo "Running pdflatex first pass..."
pdflatex $1.tex || echo "Warning: pdflatex first pass failed"

echo "Running bibtex..."
bibtex $1 || echo "Warning: bibtex failed"

echo "Running pdflatex second pass..."
pdflatex $1.tex || echo "Warning: pdflatex second pass failed"

echo "Running pdflatex third pass..."
pdflatex $1.tex || echo "Warning: pdflatex third pass failed"

