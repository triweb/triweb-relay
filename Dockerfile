FROM ubuntu:focal
LABEL Description="Triweb Relay Server" Vendor="-" Version="0.1"

ARG RESTY_LUAROCKS_VERSION=3.8.0

# HTTP and HTTPS ports for triweb-container and websockets
EXPOSE 80
EXPOSE 443

# WebRTC ports - RTP port, TURN port
# @see https://flashphoner.com/how-to-use-docker-with-webrtc-in-production/
# EXPOSE 5004
# EXPOSE 3478

# Update and install base system packages
RUN apt-get --yes update && apt-get --yes upgrade && DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
    build-essential \
    apt-transport-https \
    curl \
    git \
    gcc \
    g++ \
    make \
    wget \
    gnupg \
    ca-certificates \
    gettext-base \
    libgd-dev \
    libgeoip-dev \
    libncurses5-dev \
    libperl-dev \
    libreadline-dev \
    libxslt1-dev \
    make \
    perl \
    unzip \
    zlib1g-dev

# Install Redis
# - to store SSL certificates issued with OpenResty auto_ssl
RUN apt-get --yes install redis-server

# Install Coturn
# RUN apt-get --yes install coturn

# Install OpenResty
RUN curl -L https://openresty.org/package/pubkey.gpg | apt-key add -
RUN echo "deb http://openresty.org/package/ubuntu focal main" > /etc/apt/sources.list.d/openresty.list
RUN apt-get --yes update && apt-get --yes install --no-install-recommends openresty openresty-resty

# Install LuaRocks
# Based on https://github.com/openresty/docker-openresty/blob/master/focal/Dockerfile
RUN cd /tmp \
    && curl -fSL https://luarocks.github.io/luarocks/releases/luarocks-${RESTY_LUAROCKS_VERSION}.tar.gz -o luarocks-${RESTY_LUAROCKS_VERSION}.tar.gz \
    && tar xzf luarocks-${RESTY_LUAROCKS_VERSION}.tar.gz \
    && cd luarocks-${RESTY_LUAROCKS_VERSION} \
    && ./configure \
        --prefix=/usr/local/openresty/luajit \
        --with-lua=/usr/local/openresty/luajit \
        --lua-suffix=jit-2.1.0-beta3 \
        --with-lua-include=/usr/local/openresty/luajit/include/luajit-2.1 \
    && make build \
    && make install \
    && cd /tmp \
    && rm -rf luarocks-${RESTY_LUAROCKS_VERSION} luarocks-${RESTY_LUAROCKS_VERSION}.tar.gz

ENV PATH=$PATH:/usr/local/openresty/luajit/bin:/usr/local/openresty/nginx/sbin:/usr/local/openresty/bin
#ENV LUA_PATH="/usr/local/openresty/site/lualib/?.ljbc;/usr/local/openresty/site/lualib/?/init.ljbc;/usr/local/openresty/lualib/?.ljbc;/usr/local/openresty/lualib/?/init.ljbc;/usr/local/openresty/site/lualib/?.lua;/usr/local/openresty/site/lualib/?/init.lua;/usr/local/openresty/lualib/?.lua;/usr/local/openresty/lualib/?/init.lua;./?.lua;/usr/local/openresty/luajit/share/luajit-2.1.0-beta3/?.lua;/usr/local/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?/init.lua;/usr/local/openresty/luajit/share/lua/5.1/?.lua;/usr/local/openresty/luajit/share/lua/5.1/?/init.lua"
#ENV LUA_CPATH="/usr/local/openresty/site/lualib/?.so;/usr/local/openresty/lualib/?.so;./?.so;/usr/local/lib/lua/5.1/?.so;/usr/local/openresty/luajit/lib/lua/5.1/?.so;/usr/local/lib/lua/5.1/loadall.so;/usr/local/openresty/luajit/lib/lua/5.1/?.so"

# Install required OpenResty modules
RUN luarocks install lua-resty-auto-ssl
RUN mkdir /etc/resty-auto-ssl && chown www-data /etc/resty-auto-ssl

# Redirect OpenResty Nginx logs to STDOUT and STDERR
RUN ln -sf /dev/stdout /usr/local/openresty/nginx/logs/access.log \
	&& ln -sf /dev/stderr /usr/local/openresty/nginx/logs/error.log

## Install Node.js
#RUN curl --silent --location https://deb.nodesource.com/setup_16.x | bash -
#RUN apt-get install --yes nodejs
#
## Install dependencies
#COPY ./src/package.json ./src/package-lock.json /srv/triweb-relay/
#WORKDIR /srv/triweb-relay
#RUN npm install --location=global coffeescript
#RUN npm install

# Install bin
COPY ./bin/docker-autorun /usr/local/bin/
RUN chmod a+x /usr/local/bin/*

# Install OpenResty configuration
COPY ./openresty /etc/openresty/

# Install triweb-client
ENV TRIWEB_CLIENT_REPO_URL="https://github.com/triweb/triweb"
ENV TRIWEB_CLIENT_BRANCH="master"
ENV TRIWEB_CLIENT_DIST_DIRECTORY="dist"
RUN git clone --depth 1 --branch $TRIWEB_CLIENT_BRANCH $TRIWEB_CLIENT_REPO_URL /srv/triweb
#COPY ./triweb /srv/triweb/

## Install triweb-relay
#COPY ./src /srv/triweb-relay
#WORKDIR /srv/triweb-relay

# Prepare /data directory and allow it to be mapped to the local volume with docker -v
RUN mkdir -p /data && chmod a+rwx /data
VOLUME /data

ENV ALLOWED_DOMAINS=*
ENV RELAY_ADDRESS=autodetect
CMD docker-autorun
