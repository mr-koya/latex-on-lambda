# Use Amazon Linux 2023 as the base image
FROM amazonlinux:2023

# Install necessary OS updates and dependencies
RUN yum update -y && \
    yum install -y wget perl-Digest-MD5 perl fontconfig tar && \
    yum clean all

# Install TinyTeX
RUN wget -qO- "https://yihui.org/tinytex/install-bin-unix.sh" | sh && \
    /root/.TinyTeX/bin/*/tlmgr path add

# Set the PATH for the installed TinyTeX
ENV PATH=/root/.TinyTeX/bin/x86_64-linux:$PATH

# Set the working directory
WORKDIR /workspace

# Set pdflatex as the entry point
ENTRYPOINT ["pdflatex"]
CMD ["--version"]

