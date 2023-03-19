FROM cloudposse/geodesic:2.0.0-alpine


ENV ASSUME_ROLE_INTERACTIVE=false
ENV AWS_SAML2AWS_ENABLED=false
ENV AWS_VAULT_ENABLED=false
ENV AWS_VAULT_SERVER_ENABLED=false

ENV HELM_VERSION 3.7.2-r0
ENV HELMFILE_VERSION 0.142.0-r0
#ENV HELM_DIFF_VERSION 3.1.3
#ENV HELM_GIT_VERSION 0.8.1

RUN apk upgrade --update \
    && apk add -u \
    	helm@cloudposse==${HELM_VERSION} \
    	helmfile@cloudposse==${HELMFILE_VERSION}

COPY entrypoint.sh /usr/local/bin/entrypoint
COPY ./root /

CMD [ "-c", "entrypoint" ]