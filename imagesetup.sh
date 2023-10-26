#!/bin/bash

set -ex

CODESERVER_URL=https://github.com/coder/code-server/releases/download/v4.18.0/code-server-4.18.0-linux-amd64.tar.gz
GOLANG_URL=https://go.dev/dl/go1.21.3.linux-amd64.tar.gz
NODEJS_URL=https://nodejs.org/dist/v21.0.0/node-v21.0.0-linux-x64.tar.xz
PYTHON_URL=https://www.python.org/ftp/python/3.12.0/Python-3.12.0.tar.xz

# Build python
# References, see:
# https://salsa.debian.org/cpython-team/python3/-/blob/master/debian/rules
# https://github.com/docker-library/python/blob/402b993af9ca7a5ee22d8ecccaa6197bfb957bc5/3.12/bookworm/Dockerfile
build_python() {
	local SRC_DIR=$1
	local DST_DIR=$2

	apt-get install -y \
		build-essential dpkg-dev \
		libbz2-dev libc6-dev libcurl4-openssl-dev libdb-dev \
		libevent-dev libffi-dev libgdbm-dev libglib2.0-dev libgmp-dev \
		libjpeg-dev libkrb5-dev liblzma-dev libmagickcore-dev libmagickwand-dev \
		libmaxminddb-dev libncurses5-dev libncursesw5-dev libpng-dev libpq-dev \
		libreadline-dev libsqlite3-dev libssl-dev libtool libwebp-dev \
		libxml2-dev libxslt-dev libyaml-dev zlib1g-dev

	local ARCH=$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)

	cd ${SRC_DIR}

	./configure \
		--build=${ARCH} \
		--prefix=${DST_DIR} \
		--enable-optimizations \
		--enable-ipv6 \
		--enable-loadable-sqlite-extensions \
		--enable-option-checking=fatal \
		--with-dbmliborder=$(dbmliborder) \
		--with-computed-gotos \
		--with-ensurepip \
		--with-system-expat \
		--with-ssl-default-suites=openssl \
		--enable-shared \
		--with-lto \
		--without-static-libpython

	make -j $(nproc)
	make install
	mkdir -p ${DST_DIR}
	cd ${DST_DIR}
	find ${DST_DIR} -depth \( \( -type d -a \( -name test -o -name tests -o -name idle_test \) \) -o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' -o -name 'libpython*.a' \) \) \) -exec rm -fr '{}' +
	echo ${DST_DIR}/lib > /etc/ld.so.conf.d/python.conf
	ldconfig
	${DST_DIR}/bin/pip3 install -r /tmp/requirements.txt
}

# Install basic packages to download and uncompress things
apt-get update --fix-missing
apt install -y curl unzip bzip2 xz-utils ca-certificates

# Download and uncompress code-server binary
curl -sSL ${CODESERVER_URL} > /tmp/code-server.tgz
mkdir -p /opt/code-server
tar xzf /tmp/code-server.tgz -C /opt/code-server --strip-components 1
rm -f /tmp/code-server.tgz

# Download and uncompress golang binary
curl -sSL ${GOLANG_URL} > /tmp/go.tgz
mkdir -p /opt/golang
tar xzf /tmp/go.tgz -C /opt/golang --strip-components 1
rm -f /tmp/go.tgz

# Download and uncompress nodejs binary
curl -sSL ${NODEJS_URL} > /tmp/node.txz
mkdir -p /opt/nodejs
tar xJf /tmp/node.txz -C /opt/nodejs --strip-components 1
rm -f /tmp/node.txz

# Download and uncompress python source
curl -sSL ${PYTHON_URL} > /tmp/python.txz
mkdir -p /tmp/python-src
tar xJf /tmp/python.txz -C /tmp/python-src --strip-components=1
rm -f /tmp/python.txz
build_python /tmp/python-src /opt/python
rm -fr /tmp/python-src
