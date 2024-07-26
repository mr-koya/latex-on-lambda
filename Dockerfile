# Use Amazon Linux 2023 as the base image
FROM amazonlinux:2023

# Set environment variables
ENV PATH=/opt/bin/aarch64-linux:$PATH
ENV LAMBDA_TASK_ROOT=/var/task
ENV AWS_LAMBDA_RUNTIME_API=127.0.0.1:8080

# Add the texlive.profile and test files
COPY support_files/* /tmp/


# Install necessary OS updates and dependencies
RUN dnf update -y && \
    dnf install -y ghostscript libgs-devel ImageMagick poppler fontconfig\
    tar perl perl-Digest-MD5 python3-pip && dnf clean all

# Install TeXLive (as a portable install) then remove the tar.gz file in one
# RUN command to save space
RUN curl -L -o install-tl-unx.tar.gz \
    https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz && \
    tar -xzf install-tl-unx.tar.gz && \
    rm install-tl-unx.tar.gz

RUN cd $(find . -maxdepth 1 -type d -name 'install-tl-*') && \
    echo "Now in directory: $(pwd)" && \
    ./install-tl --profile=/tmp/texlive.profile

# Test the TeX setup
RUN cd /tmp && \
	pdflatex apssamp.tex && bibtex apssamp && pdflatex apssamp.tex && pdflatex apssamp

# Clean up the installation files
RUN rm -r install-tl-* /tmp/*

# Install AWS Lambda runtime interface client and other Python dependencies
RUN pip3 install awslambdaric requests

# Install AWS Lambda Runtime Interface Emulator
ADD https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/latest/download/aws-lambda-rie /usr/local/bin/aws-lambda-rie
RUN chmod +x /usr/local/bin/aws-lambda-rie

# Copy application code
COPY src/ ${LAMBDA_TASK_ROOT}/

# Change the working directory
WORKDIR ${LAMBDA_TASK_ROOT}

# Make the LaTeX compilation script executable
RUN chmod +x compile_tex.sh

# Set the entrypoint to the AWS Lambda Runtime Interface Emulator
ENTRYPOINT ["/usr/local/bin/aws-lambda-rie", "python3", "-m", "awslambdaric"]

# Set the CMD to your handler
CMD ["app.lambda_handler"]

