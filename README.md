# Sample WebDyne Application

This repo demonstrates a very simple self-contained WebDyne application which can be run locally or deployed to a Docker container. You can see it running at Sevalla:

https://psp-webdyne-fortunedocker-yvu4v.sevalla.app

> [!NOTE]
>
> The app self-hibernates after 5 minutes to save costs. If you get an error accessing the link try again after 10 seconds so it has had time to spin up.

## Local Deployment

To deploy this app to a local machine with an existing Perl installation including App::cpanminus (cpanm)

```bash
# Install the WebDyne and Plack modules
#
cpanm Task::WebDyne::Plack

# Or separately using legacy cpan if cpanm not available
#
cpan WebDyne
cpan Plack

# Clone the repo
#
git clone https://github.com/aspeer/psp-WebDyne-Fortune.git
cd psp-WebDyne-Fortune.git

# Start webdyne using the current directory as context
#
webdyne.psgi .

# To start on a different port than 5000
#
webdyne.psgi --port=5002 .
```

## Docker Deploy from Registry

```bash
# Run directly from registry
#
docker run -p 8080:8080 --name webdyne-fortune ghcr.io/aspeer/psp-webdyne-fortune:latest

# Run on different port
#
docker run -e PORT=5004 -p 5004:5004 --name webdyne-fortune ghcr.io/aspeer/psp-webdyne-fortune:latest

# Run in background
#
docker run -d -p 8080:8080 --name webdyne-fortune ghcr.io/aspeer/psp-webdyne-fortune:latest

```

## Docker Build and Run

```bash
# Clone the repo
#
git clone https://github.com/aspeer/psp-WebDyne-Fortune.git
cd psp-WebDyne-Fortune.git

# Build 
#
docker build -t webdyne-fortune:latest .

# Run
#
docker run -p 8080:8080 webdyne-fortune

# To start on a different port than 8080
#
docker run -e PORT=5002 -p 5002:5002 webdyne-fortune
```

## Carton Deployment

```bash
#  Assumes carton installed, if not install
#
cpanm install --notest Carton

# Clone the repo
#
git clone https://github.com/aspeer/psp-WebDyne-Fortune.git
cd psp-WebDyne-Fortune.git

#  Deploy locally
#
carton install --deployment

# Run
#
WEBDYNE_CONF=./webdyne.conf.pl carton exec webdyne.psgi

# Start on a different port
#
WEBDYNE_CONF=./webdyne.conf.pl carton exec webbdyne.psgi --port=5004 

```

## Starman

```bash
# Net::Server fails test but still works on some modern distros. Force install
#
cpanm --force Net::Server

# Install the WebDyne and Starman modules
#
cpanm Task::WebDyne::Starman

# Clone the repo
#
git clone https://github.com/aspeer/psp-WebDyne-Fortune.git
cd psp-WebDyne-Fortune.git

# Start Starman
#
starman $(which webdyne.psgi) .

# Start on a different port
#
starman $(which webdyne.psgi) --port 5002 .

```

