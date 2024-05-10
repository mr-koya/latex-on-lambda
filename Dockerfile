# Start with the base image for Python provided by AWS Lambda
FROM public.ecr.aws/lambda/python:3.9

# Install system updates and essential LaTeX packages
RUN yum update -y && \
    yum install -y \
    texlive-latex \
    texlive-xetex \
    texlive-luatex \
    texlive-latex-recommended \
    texlive-fonts-recommended \
    ghostscript && \
    yum clean all

# Copy the Python function code
COPY src/ ${LAMBDA_TASK_ROOT}

# Install Python dependencies
COPY requirements.txt .
RUN python -m pip install --no-cache-dir -r requirements.txt

# Copy LaTeX templates if needed
COPY templates/ ${LAMBDA_TASK_ROOT}/templates/

# Set the CMD to your handler (this is the entry point for the Lambda function)
CMD ["app.handler"]

