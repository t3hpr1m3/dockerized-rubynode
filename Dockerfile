FROM debian:stretch-slim

ARG RUBY_MINOR_VERSION=2.1
ARG RUBY_VERSION=2.1.7
ARG NODE_VERSION=12.13.0
ARG BUNDLER_VERSION=1.9.7
ARG MAKE_JOBS=2
ARG PHANTOMJS_VERSION=1.9.8

RUN apt-get update && \
	apt-get remove \
		bundler \
		gem \
		nodejs \
		ruby \
		ruby1.8 && \
	apt-get install -y --no-install-recommends \
		autoconf \
		bison \
		build-essential \
		ca-certificates \
		curl \
		git-core \
		gnupg \
		libffi-dev \
		libgdbm-dev \
		libgdbm3 \
		libncurses5-dev \
		libpq-dev \
		libqtwebkit-dev \
		libreadline6-dev \
		libssl1.0-dev \
		libxml2-dev \
		libxslt-dev \
		libyaml-dev \
		pdftk \
		procps \
		python \
		qt4-default \
		software-properties-common \
		xauth \
		xvfb \
		zlib1g-dev && \
	add-apt-repository 'deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main' && \
	curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
	apt-get update && \
	apt-get install -y --no-install-recommends \
		postgresql-client-9.4 && \
	mkdir -p /usr/local/src/ && \
	cd /usr/local/src && \
	curl -SLO "https://cache.ruby-lang.org/pub/ruby/${RUBY_MINOR_VERSION}/ruby-${RUBY_VERSION}.tar.gz" && \
	curl -SL "https://gist.githubusercontent.com/mislav/055441129184a1512bb5/raw" -o /usr/local/src/ruby-openssl.patch && \
	curl -SLO "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}.tar.gz" && \
	tar -xf "ruby-${RUBY_VERSION}.tar.gz" && \
	tar -xf "node-v${NODE_VERSION}.tar.gz" && \
	cd "/usr/local/src/ruby-${RUBY_VERSION}" && \
	patch -p1 < /usr/local/src/ruby-openssl.patch && \
	./configure --disable-install-rdoc && \
	make -j${MAKE_JOBS} && \
	make install && \
	gem install bundler --no-document -v ${BUNDLER_VERSION} && \
	cd "/usr/local/src/node-v${NODE_VERSION}/" && \
	./configure && \
	make -j${MAKE_JOBS} && \
	make install && \
	cd /usr/local/src/ && \
	rm -rf "ruby-${RUBY_VERSION}" ruby-openssl.patch "node-v${NODE_VERSION}" && \
	curl -SL https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-${PHANTOMJS_VERSION}-linux-x86_64.tar.bz2 | tar --strip-components=1 --no-anchored -xjvf - -C /usr/local/ bin/phantomjs

WORKDIR /usr/src/app

EXPOSE 3000
