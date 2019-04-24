FROM ubuntu:18.04

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  sudo \
  whois \
  git \
  wget \
  curl \
  ca-certificates \
  locales \
  tzdata &&\
  apt-get install -y --no-install-recommends \
    fonts-dejavu \
    build-essential \
    gfortran

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# install Python + NodeJS with conda
RUN wget -q https://repo.continuum.io/miniconda/Miniconda3-4.5.11-Linux-x86_64.sh -O /tmp/miniconda.sh  && \
    bash /tmp/miniconda.sh -f -b -p /opt/conda && \
    /opt/conda/bin/conda install --yes -c conda-forge \
      python=3.6 sqlalchemy tornado jinja2 traitlets requests pip pycurl \
      nodejs configurable-http-proxy notebook && \
    /opt/conda/bin/pip install --upgrade pip && \
    rm /tmp/miniconda.sh
ENV PATH=/opt/conda/bin:$PATH

RUN mkdir -p /srv/jupyterhub/
RUN mkdir -p /etc/skel/notebook
WORKDIR /srv/jupyterhub/

RUN pip install jupyterhub

RUN mkdir -p /etc/skel/.jupyter
RUN echo "c.NotebookApp.terminado_settings={'shell_command': ['bash']}" > /etc/skel/.jupyter/jupyter_notebook_config.py

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    libnss-ldap libpam-ldap ldap-auth-client
RUN apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY ldap-auth-config /etc/auth-client-config/profile.d/ldap-auth-config
RUN auth-client-config -a -p lac_ldap

ENV NB_UID        1000
ENV NB_USER       jupyter
ENV NB_HOME       /home/jupyter
ENV NB_PASSWORD   jupyter
ENV NB_GID        1000
ENV NB_GROUP      jupyter
ENV NB_GRANT_SUDO nopass
ENV NB_PORT       8000

ENV LDAP_SERVER        192.168.1.10
ENV LDAP_BASE_DN       dc=example,dc=net

COPY entrypoint.sh /entrypoint.sh

EXPOSE $NB_PORT

CMD ["/entrypoint.sh"]
