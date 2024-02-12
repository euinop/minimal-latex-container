# Build a minimal docker image for compiling LaTeX documents in-place.
FROM alpine:latest

# Install a minimal LaTeX distribution.
RUN apk update && apk add texmf-dist texlive texlive-luatex texlive-xetex

# Add texlive.profile file.
COPY ./texlive.profile /tmp/texlive.profile

# Download and install TeX Live.
RUN apk add --no-cache perl wget xz
RUN wget http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
RUN mkdir /tmp/install-tl
RUN tar -xzf install-tl-unx.tar.gz -C /tmp/install-tl --strip-components=1
RUN /tmp/install-tl/install-tl --profile=/tmp/texlive.profile

# After installation, add some paths to PATH, as suggested by the installer.
ENV PATH="/usr/local/texlive/2023/bin/x86_64-linuxmusl:${PATH}"
ENV MANPATH="/usr/local/texlive/2023/texmf-dist/doc/man:${MANPATH}"
ENV INFOPATH="/usr/local/texlive/2023/texmf-dist/doc/info:${INFOPATH}"

# Update tlmgr and install desired packages.
RUN tlmgr update --self --all && \
    tlmgr install pdfx

# Install fonts.
RUN apk --no-cache add msttcorefonts-installer fontconfig && \
    update-ms-fonts && \
    fc-cache -f

RUN apk --no-cache add font-carlito && \
    fc-cache -f

# Set working directory.
WORKDIR /latex

# Define an entry point (optional).
CMD ["pdflatex", "--version"]

LABEL maintainer="eugenio.pino@icloud.com"
LABEL version="0.1"
LABEL description="Minimal Alpine-based LaTeX Docker image"
