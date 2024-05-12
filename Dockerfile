# Use Amazon Linux 2023 as the base image
FROM amazonlinux:2023

# Install necessary OS updates and dependencies
RUN yum update -y && \
    yum install -y wget perl-Digest-MD5 perl fontconfig tar && \
    yum clean all

# Download and install TinyTeX
RUN wget -qO- "https://yihui.org/tinytex/install-bin-unix.sh" | sh \
    && /root/.TinyTeX/bin/*/tlmgr path add

# Set the PATH for the installed TinyTeX
ENV PATH=/root/.TinyTeX/bin/x86_64-linux:$PATH

# Install additional LaTeX packages
RUN tlmgr install amsmath amsfonts revtex4-1 textcase bibtex

# Copy LaTeX project files
COPY src/compile_tex.sh /workspace/compile_tex.sh
COPY templates/example_template.tex /workspace/example_template.tex
COPY templates/references.bib /workspace/references.bib

# Make the LaTeX compilation script executable
RUN chmod +x /workspace/compile_tex.sh

# Set the working directory to the workspace
WORKDIR /workspace

# Set the entry point to the compilation script
ENTRYPOINT ["/workspace/compile_tex.sh"]

# Set the default parameter for the entry point script
CMD ["default"]

