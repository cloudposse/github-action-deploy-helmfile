FROM python:3.11.2-slim-buster


ENV HELM_VERSION 3.7.2
ENV HELMFILE_VERSION 0.142.0
# Helm plugins:
# https://github.com/databus23/helm-diff/releases
ENV HELM_DIFF_VERSION 3.6.0
# https://github.com/aslafy-z/helm-git/releases
# We had issues with helm-diff 3.1.3 + helm-git 0.9.0,
# previous workaround was to pin helm-git to version 0.8.1.
# We expect this has been fixed now with helm-diff 3.3.2 + helm-git 0.11.1
ENV HELM_GIT_VERSION 0.15.1
ENV KUBECTL_VERSION 0.15.1

ENV HELM_DATA_HOME   /root/.local/share/helm
ENV HELM_CONFIG_HOME /root/.config/helm
ENV HELM_CACHE_HOME  /root/.cache/helm

RUN pip install awscli
RUN apt-get update && apt-get install -y apt-utils curl
RUN curl -1sLf 'https://dl.cloudsmith.io/public/cloudposse/packages/cfg/setup/bash.deb.sh' | bash

RUN apt-get update && apt-get install -y \
     	bash \
    	yq \
    	jq \
    	git \
    	kubectl \
    	chamber \
    	helm \
    	helmfile

RUN helm plugin install https://github.com/databus23/helm-diff --version v${HELM_DIFF_VERSION} \
    && helm plugin install https://github.com/aslafy-z/helm-git --version ${HELM_GIT_VERSION} \
    && rm -rf $XDG_CACHE_HOME/helm

COPY entrypoint.sh /usr/local/bin/entrypoint
COPY ./root /
ENTRYPOINT [ "/usr/local/bin/entrypoint" ]