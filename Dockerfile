FROM alpine:3.2

ENV RUBY_VERSION 2.4.0
ENV NODE_VERSION 6.9.2

RUN apk --update add --virtual .build-deps \
		bash \
		build-base \
		g++ \
		gcc \
		git \
		gnupg \
		libxml2-dev \
		libxslt-dev \
		linux-headers \
		openssl-dev \
		readline-dev \
		tar \
		xz && \
	git clone http://github.com/rbenv/ruby-build.git /root/ruby-build && \
	/root/ruby-build/install.sh && \
	rm -rf /root/ruby-build && \
	ruby-build $RUBY_VERSION /usr/local && \
	for key in \
		9554F04D7259F04124DE6B476D5A82AC7E37093B \
		94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
		0034A06D9D9B0064CE8ADF6BF1747F4AD2306D93 \
		FD3A5288F042B6850C66B31F09FE44734EB7990E \
		71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
		DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
		B9AE9905FFD7803F25714661B63B535A4C206CA9 \
		C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
	; do \
		gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
	done && \
	cd /tmp && \
	curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION.tar.xz" && \
	curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" && \
	gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc && \
	grep " node-v$NODE_VERSION.tar.xz\$" SHASUMS256.txt | sha256sum -c - && \
	tar -xf "node-v$NODE_VERSION.tar.xz" && \
	rm "node-v$NODE_VERSION.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt && \
	cd "/tmp/node-v$NODE_VERSION" && \
	./configure && \
	make -j$(getconf _NPROCESSORS_ONLN) && \
	make install && \
	cd /tmp && rm -Rf "node-v$NODE_VERSION" && \
	apk del .build-deps && \
	rm -rf /var/cache/apk/*
