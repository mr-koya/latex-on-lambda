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

# Install AWS Lambda Runtime Interface Client for Python
RUN python3 -m pip install awslambdaric

# Copy the LaTeX and Python handler files
COPY src/compile_tex.sh /var/task/compile_tex.sh
COPY src/app.py /var/task/app.py
COPY templates/ /var/task/templates/
COPY test_lambda.py /var/task/test_lambda.py

# Make the LaTeX compilation script executable
RUN chmod +x /var/task/compile_tex.sh

# Set the working directory to the Lambda task folder
WORKDIR /var/task

# Create a directory for output
RUN mkdir -p /var/task/output

# Install the AWS Lambda Runtime Interface Emulator
ADD https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/latest/download/aws-lambda-rie /usr/local/bin/aws-lambda-rie
RUN chmod +x /usr/local/bin/aws-lambda-rie

# The entry point configures AWS Lambda to use the custom runtime
ENTRYPOINT ["/usr/local/bin/aws-lambda-rie", "/usr/bin/python3", "-m", "awslambdaric"]
CMD ["app.lambda_handler"]

