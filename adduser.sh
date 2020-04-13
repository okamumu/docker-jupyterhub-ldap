#!/bin/bash
username="${1}"

adduser -q --gecos "" --home "${NB_VOLUME}/${username}" --gid "${NB_GID}" --disabled-password "${username}"
