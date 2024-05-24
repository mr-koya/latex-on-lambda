# Use Amazon Linux 2023 as the base image
FROM amazonlinux:2023

# Set environment variables
ENV PATH=/root/.TinyTeX/bin/x86_64-linux:$PATH
ENV LAMBDA_TASK_ROOT=/var/task
ENV AWS_LAMBDA_RUNTIME_API=127.0.0.1:8080

# Install necessary OS updates and dependencies
RUN dnf update -y && \
    dnf install -y wget perl-Digest-MD5 perl fontconfig tar python3-pip && \
    dnf clean all

# Install TinyTeX
RUN wget -qO- "https://yihui.org/tinytex/install-bin-unix.sh" | sh && \
    /root/.TinyTeX/bin/*/tlmgr path add

# Install additional LaTeX packages
RUN tlmgr init-usertree && \
    tlmgr install amsmath amsfonts textcase bibtex

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

