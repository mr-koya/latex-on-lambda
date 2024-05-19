# Use Amazon Linux 2023 as the base image
FROM public.ecr.aws/lambda/provided.al2023 

# Install necessary OS updates and dependencies for LaTeX and Python
RUN dnf update -y && \
    dnf install -y wget perl-Digest-MD5 perl fontconfig tar python3 python3-pip && \
    dnf clean all

# Download and install TinyTeX
RUN wget -qO- "https://yihui.org/tinytex/install-bin-unix.sh" | sh \
    && /root/.TinyTeX/bin/*/tlmgr path add

# Set the PATH for the installed TinyTeX
ENV PATH=/root/.TinyTeX/bin/x86_64-linux:$PATH

# Install additional LaTeX packages
RUN tlmgr install amsmath amsfonts revtex4-1 textcase bibtex

# Install AWS Lambda Runtime Interface Client for Python
RUN pip3 install awslambdaric

# Copy the LaTeX and Python handler files
COPY src/compile_tex.sh /var/task/compile_tex.sh
COPY src/app.py /var/task/app.py
COPY templates/ /var/task/templates/

# Make the LaTeX compilation script executable
RUN chmod +x /var/task/compile_tex.sh

# Set the working directory to the Lambda task folder
WORKDIR /var/task

# The entry point configures AWS Lambda to use the custom runtime
ENTRYPOINT [ "/usr/bin/python3"], "-m", "awslambdaric" ]
CMD ["app.py"]

