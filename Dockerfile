FROM ghcr.io/aspeer/webdyne:alpine
WORKDIR /app
COPY app.* .
COPY app_*.psp .
COPY perl .
COPY perl.* .
COPY cpanfile .
RUN cpanm --with-recommends --installdeps . && rm -f cpanfile
COPY .webdyne.conf.pl /app
