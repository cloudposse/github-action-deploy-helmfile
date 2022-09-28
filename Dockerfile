FROM alpine:3.14

RUN sed -i 's|http://dl-cdn.alpinelinux.org|https://alpine.global.ssl.fastly.net|g' /etc/apk/repositories
# The PyYAML Python package requires "Cython" to build as of 2022-05-15
RUN apk add --update -U python3 python3-dev py3-pip libffi-dev gcc linux-headers musl-dev openssl-dev make

ADD https://apk.cloudposse.com/ops@cloudposse.com.rsa.pub /etc/apk/keys/
RUN echo "@cloudposse https://apk.cloudposse.com/3.11/vendor" >> /etc/apk/repositories

# install the cloudposse alpine repository
ADD https://apk.cloudposse.com/ops@cloudposse.com.rsa.pub /etc/apk/keys/
RUN echo "@cloudposse https://apk.cloudposse.com/3.13/vendor" >> /etc/apk/repositories

# Use TLS for alpine default repos
RUN sed -i 's|http://dl-cdn.alpinelinux.org|https://alpine.global.ssl.fastly.net|g' /etc/apk/repositories && \
    echo "@testing https://alpine.global.ssl.fastly.net/alpine/edge/testing" >> /etc/apk/repositories && \
    echo "@community https://alpine.global.ssl.fastly.net/alpine/edge/community" >> /etc/apk/repositories

##########################################################################################
# See Dockerfile.options for how to install `glibc` for greater compatibility, including #
# being able to use AWS CLI v2. You would install `glibc` and `libc6-compat` here, then  #
# install the packages below, then the Python stuff, then move AWS CLI v1 aside, and     #
# then install the AWS CLI v2                                                            #
##########################################################################################

# Install alpine package manifest
COPY packages.txt  /etc/apk/

## Here is where we would copy in the repo checksum in an attempt to ensure updates bust the Docker build cache

RUN apk add --update $(grep -h -v '^#' /etc/apk/packages.txt) && \
    mkdir -p /etc/bash_completion.d/ /etc/profile.d/ /conf && \
    touch /conf/.gitconfig

COPY requirements.txt /requirements.txt

# The cryptography package has to be built specially for Alpine before it can be installed,
# so we have to install it on the "host" (which builds a wheel) before installing for the distribution.
# As of 2022-05-15 PyYAML also requires the installation of Cython for some reason, although
# it does not appear to actually use it. Seems like a build tool configuration issue,
# so we are not pinning Cython or putting it in requrements.txt becuase Debian does not need it.
RUN python3 -m pip install --upgrade pip setuptools wheel && \
    pip install $(grep cryptography /requirements.txt) Cython && \
    pip install -r /requirements.txt --ignore-installed --prefix=/dist --no-build-isolation --no-warn-script-location


# Here is where we would confirm that the package repo checksum is what we expect (not mismatched due to Docker layer cache)

RUN echo "net.ipv6.conf.all.disable_ipv6=0" > /etc/sysctl.d/00-ipv6.conf

ENV HELM_VERSION 3.7.2-r0
ENV HELMFILE_VERSION 0.142.0-r0

ENTRYPOINT ["/bin/bash"]

COPY entrypoint.sh /usr/local/bin/entrypoint
COPY ./root /

CMD [ "-c", "entrypoint" ]

#FROM cloudposse/geodesic:0.147.11-alpine
#
#
#ENV HELM_VERSION 3.7.2-r0
#ENV HELMFILE_VERSION 0.142.0-r0
##ENV HELM_DIFF_VERSION 3.1.3
##ENV HELM_GIT_VERSION 0.8.1
#
#RUN apk upgrade --update \
#    && apk add -u \
#    	helm@cloudposse==${HELM_VERSION} \
#    	helmfile@cloudposse==${HELMFILE_VERSION}
#
#COPY entrypoint.sh /usr/local/bin/entrypoint
#COPY ./root /
#
#CMD [ "-c", "entrypoint" ]