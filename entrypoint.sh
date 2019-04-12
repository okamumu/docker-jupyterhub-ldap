#!/bin/sh

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

## ldap

echo "base $LDAP_BASE_DN" > /etc/ldap.conf
echo "uri ldap://$LDAP_SERVER/" >> /etc/ldap.conf
echo "ldap_version 3" >> /etc/ldap.conf
echo "rootbinddn cn=manager,$LDAP_BASE_DN" >> /etc/ldap.conf
echo "pam_password md5" >> /etc/ldap.conf
echo "nss_initgroups_ignoreusers backup,bin,daemon,games,gnats,irc,libuuid,list,lp,mail,man,news,proxy,root,sshd,sync,sys,syslog,uucp,www-data" >> /etc/ldap.conf

## conf

echo "c.Authenticator.admin_users = {'$NB_USER'}" > /srv/jupyterhub/jupyterhub_config.py
echo "c.Spawner.notebook_dir = \"~/notebook\"" >> /srv/jupyterhub/jupyterhub_config.py
echo "c.JupyterHub.admin_access = True" >> /srv/jupyterhub/jupyterhub_config.py

## jupyterhub
jupyterhub -f /srv/jupyterhub/jupyterhub_config.py
