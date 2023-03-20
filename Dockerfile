FROM python:3.11.2-slim-buster


ENV HELM_VERSION 3.7.2
ENV HELMFILE_VERSION 0.142.0
#ENV HELM_DIFF_VERSION 3.1.3
#ENV HELM_GIT_VERSION 0.8.1

RUN pip install awscli
RUN apt-get update && apt-get install -y apt-utils curl
RUN curl -1sLf 'https://dl.cloudsmith.io/public/cloudposse/packages/cfg/setup/bash.deb.sh' | bash

RUN apt-get update && apt-get install -y \
    	chamber \
    	helm \
    	helmfile

COPY entrypoint.sh /usr/local/bin/entrypoint
COPY ./root /

CMD [ "-c", "entrypoint" ]