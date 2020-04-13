# docker-jupyterhub

A Docker image for JupyterHub

## Usage

```
docker run -it --rm 
  -p 8000:8000
  -e NB_UID=1000
  -e NB_USER=jupyter
  -e NB_PASSWORD=jupyter
  -e NB_GID=1000
  -e NB_GROUP=jupyter
  -e NB_GRANT_SUDO=nopass
  -e NB_PORT=8000
  -e NB_VOLUME=/home
  -e GITHUB_CLIENT_ID=<id>
  -e GITHUB_CLIENT_SECRET=<secret>
  -e OAUTH_CALLBACK_URL=<callback url>
  jupyterhub
```
