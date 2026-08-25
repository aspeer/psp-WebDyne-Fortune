# Sample WebDyne Application

This repo demonstrates a simple self-contained WebDyne fortune application that
can be run as a generic Docker container.

You can see it running at Sevalla:

https://psp-webdyne-fortunedocker-yvu4v.sevalla.app

> [!NOTE]
>
> The app self-hibernates after 5 minutes to save costs. If you get an error
> accessing the link, try again after 10 seconds so it has time to spin up.

AWS Lambda deployment is documented separately in [AWS.md](AWS.md).

## Docker Deploy From Registry

```bash
# Run directly from registry
docker run -p 8080:8080 --name webdyne-fortune ghcr.io/aspeer/psp-webdyne-fortune:latest

# Run on a different port
docker run -e PORT=5004 -p 5004:5004 --name webdyne-fortune ghcr.io/aspeer/psp-webdyne-fortune:latest

# Run in the background
docker run -d -p 8080:8080 --name webdyne-fortune ghcr.io/aspeer/psp-webdyne-fortune:latest
```

## Docker Build And Run

```bash
# Clone the repo
git clone https://github.com/aspeer/psp-WebDyne-Fortune.git
cd psp-WebDyne-Fortune

# Build
docker build -t webdyne-fortune:latest .

# Run
docker run -p 8080:8080 webdyne-fortune:latest

# Run on a different port
docker run -e PORT=5002 -p 5002:5002 webdyne-fortune:latest
```
