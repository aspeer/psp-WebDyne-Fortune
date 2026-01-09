FROM ghcr.io/aspeer/webdyne:alpine
WORKDIR /app
COPY app.* .
COPY perl .
COPY perl.* .
COPY cpanfile .
RUN cpanm --installdeps . && rm -f cpanfile
COPY webdyne.conf.pl /etc
