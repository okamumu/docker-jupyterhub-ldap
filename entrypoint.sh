#!/bin/sh

mkdir -p /etc/skel/workspace
mkdir -p /etc/skel/.jupyter
echo "c.NotebookApp.terminado_settings={'shell_command': ['bash']}" > /etc/skel/.jupyter/jupyter_notebook_config.py

echo "from oauthenticator.github import LocalGitHubOAuthenticator" >> /srv/jupyterhub/jupyterhub_config.py
echo "c.JupyterHub.authenticator_class = LocalGitHubOAuthenticator" >> /srv/jupyterhub/jupyterhub_config.py
echo "c.LocalGitHubOAuthenticator.oauth_callback_url = '$OAUTH_CALLBACK_URL'" >> /srv/jupyterhub/jupyterhub_config.py
echo "c.LocalGitHubOAuthenticator.client_id = '$GITHUB_CLIENT_ID'" >> /srv/jupyterhub/jupyterhub_config.py
echo "c.LocalGitHubOAuthenticator.client_secret = '$GITHUB_CLIENT_SECRET'" >> /srv/jupyterhub/jupyterhub_config.py
echo "c.LocalAuthenticator.create_system_users = True" >> /srv/jupyterhub/jupyterhub_config.py
echo "c.Authenticator.admin_users = {'$NB_USER'}" >> /srv/jupyterhub/jupyterhub_config.py
echo "c.JupyterHub.port = $NB_PORT" >> /srv/jupyterhub/jupyterhub_config.py
echo "c.JupyterHub.admin_access = True" >> /srv/jupyterhub/jupyterhub_config.py
echo "c.Spawner.default_url = '/lab'" >> /srv/jupyterhub/jupyterhub_config.py
echo "c.Spawner.notebook_dir = \"~/workspace\"" >> /srv/jupyterhub/jupyterhub_config.py

# create user

groupadd -f -g $NB_GID $NB_GROUP || exit 1
useradd -d $NB_HOME -u $NB_UID -g $NB_GID -p `echo "$NB_PASSWORD" | mkpasswd -s -m sha-512` $NB_USER || exit 1

if [ $NB_GRANT_SUDO = "yes" ]; then
  echo "$NB_USER ALL=(ALL) ALL" >> /etc/sudoers.d/$NB_USER
elif [ $NB_GRANT_SUDO = "nopass" ]; then
  echo "$NB_USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$NB_USER
fi

mkdir -p $NB_HOME
chown $NB_USER:$NB_GROUP $NB_HOME
su - $NB_USER -c "cp -n -r --preserve=mode /etc/skel/. $NB_HOME"

## jupyterhub
jupyterhub -f /srv/jupyterhub/jupyterhub_config.py
