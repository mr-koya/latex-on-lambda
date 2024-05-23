# Use Amazon Linux 2023 as the base image
FROM public.ecr.aws/lambda/python:3.12

# Install necessary OS updates and dependencies for LaTeX and Python
RUN dnf update -y && \
    dnf install -y wget perl-Digest-MD5 perl fontconfig tar python3 python3-pip texlive texlive-scheme-medium && \
    dnf clean all

# Set the PATH for the installed TeX Live
ENV PATH=/usr/local/texlive/2023/bin/x86_64-linux:$PATH

# Install additional LaTeX packages
RUN tlmgr init-usertree && \
    tlmgr install amsmath amsfonts textcase bibtex

# Copy requirements and install dependencies
COPY requirements.txt ${LAMBDA_TASK_ROOT}
RUN pip install -r requirements.txt

# Copy application code and templates
COPY src/ ${LAMBDA_TASK_ROOT}/
COPY templates/ ${LAMBDA_TASK_ROOT}/templates/

# Make the LaTeX compilation script executable
RUN chmod +x ${LAMBDA_TASK_ROOT}/compile_tex.sh

# Set the CMD to your handler
CMD ["app.lambda_handler"]

