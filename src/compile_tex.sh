#!/bin/bash

TEX_FILE=$1
OUTPUT_DIR=$2

# Create output directory if it does not exist
mkdir -p $OUTPUT_DIR

# Log start time
echo "Starting LaTeX compilation at $(date)" >> $OUTPUT_DIR/compile.log

# First pass of pdflatex to generate .aux file
echo "Running pdflatex (first pass)..." >> $OUTPUT_DIR/compile.log
pdflatex -interaction=nonstopmode -output-directory=$OUTPUT_DIR $TEX_FILE >> $OUTPUT_DIR/compile.log 2>&1
if [ $? -ne 0 ]; then
    echo "LaTeX compilation failed at first pass. See compile.log for details." >> $OUTPUT_DIR/compile.log
    cat $OUTPUT_DIR/compile.log
    exit 1
fi

# Copy the .bib file to the output directory
BIB_FILE="$(dirname $TEX_FILE)/references.bib"
cp $BIB_FILE $OUTPUT_DIR

# Run bibtex to process the bibliography
echo "Running bibtex..." >> $OUTPUT_DIR/compile.log
cd $OUTPUT_DIR
bibtex $(basename $TEX_FILE .tex) >> compile.log 2>&1
if [ $? -ne 0 ]; then
    echo "BibTeX processing failed. See compile.log for details." >> compile.log
    cat compile.log
    exit 1
fi

# Run pdflatex two more times to resolve references
echo "Running pdflatex (second pass)..." >> $OUTPUT_DIR/compile.log
pdflatex -interaction=nonstopmode -output-directory=$OUTPUT_DIR $TEX_FILE >> $OUTPUT_DIR/compile.log 2>&1

echo "Running pdflatex (third pass)..." >> $OUTPUT_DIR/compile.log
pdflatex -interaction=nonstopmode -output-directory=$OUTPUT_DIR $TEX_FILE >> $OUTPUT_DIR/compile.log 2>&1

# Check if the final PDF is generated
if [ -f "${OUTPUT_DIR}/$(basename $TEX_FILE .tex).pdf" ]; then
    echo "PDF generated successfully at $(date)." >> $OUTPUT_DIR/compile.log
else
    echo "PDF generation failed. See compile.log for details." >> $OUTPUT_DIR/compile.log
    cat compile.log
    exit 1
fi

# Log end time
echo "LaTeX compilation completed at $(date)." >> $OUTPUT_DIR/compile.log

