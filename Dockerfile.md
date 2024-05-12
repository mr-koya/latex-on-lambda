## Dockerfile Documentation

### 1. Base Image
```docker
FROM amazonlinux:2023
```
This line sets Amazon Linux 2023 as the base image for your Docker container, providing a secure and stable environment optimized for AWS services.

### 2. Installing Dependencies
```docker
RUN yum update -y && \
    yum install -y wget perl-Digest-MD5 perl fontconfig tar && \
    yum clean all
```
This command updates the system and installs necessary dependencies:
- `wget`: For downloading files such as the TinyTeX installation script.
- `perl` and `perl-Digest-MD5`: For script support; some LaTeX packages may require Perl scripts.
- `fontconfig`: For managing and customizing font access, crucial for LaTeX document rendering.
- `tar`: For extracting compressed files.
The `yum clean all` command clears the YUM cache, reducing the image size by removing unnecessary data.

### 3. Installing TinyTeX
```docker
RUN wget -qO- "https://yihui.org/tinytex/install-bin-unix.sh" | sh && \
    /root/.TinyTeX/bin/*/tlmgr path add
```
This line downloads and executes the TinyTeX installation script from Yihui Xie's website. After installing TinyTeX, `tlmgr path add` ensures that the TinyTeX binaries are correctly added to the system `PATH`.

### 4. Setting the Environment Variable
```docker
ENV PATH=/root/.TinyTeX/bin/x86_64-linux:$PATH
```
This environment variable explicitly sets the `PATH` to include the TinyTeX binary directory, ensuring that LaTeX commands are available system-wide and can be executed from any terminal session, interactive or non-interactive.

### 5. Adding a Non-root User
```docker
RUN adduser --shell /bin/bash latexuser && \
    chown -R latexuser:latexuser /home/latexuser
USER latexuser
WORKDIR /home/latexuser
```
- `adduser`: Adds a non-root user named 'latexuser' to enhance security by running the container processes under a user with limited system permissions.
- `chown`: Changes the ownership of the user's home directory to `latexuser`, ensuring that the user has appropriate access rights to their own files.
- `USER`: Switches to the `latexuser` to run all subsequent commands.
- `WORKDIR`: Sets `/home/latexuser` as the working directory where all operations will be performed by default.

### 6. Entrypoint and CMD
```docker
ENTRYPOINT ["pdflatex"]
CMD ["--version"]
```
`ENTRYPOINT` is set to `pdflatex`, making it the default executable for the container. The `CMD` provides the default arguments (`--version`) to the entry point, which can be overridden when the container is invoked with additional parameters. This setup allows for direct processing of `.tex` files by simply passing the file names as arguments to the Docker container.

