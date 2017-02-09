FROM lsiobase/alpine:35
MAINTAINER sparklyballs

# package version
ARG RDIFF_VER="1.2.8"

# environment settings
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS="2"

# copy patches
COPY patches/ /tmp/patches/

# install build packages
RUN \
 apk add --no-cache --virtual=build-dependencies \
	curl \
	g++ \
	gcc \
	librsync-dev \
	python-dev \
	tar && \

# install runtime packages
 apk add --no-cache \
	expat \
	gdbm \
	libbz2 \
	libffi \
	librsync \
	openssh \
	popt \
	python2 \
	sqlite-libs && \

# build rdiff-backup
 mkdir -p \
	/tmp/rdiff-src && \
 curl -o \
 /tmp/rdiff.tar.gz -L \
	"http://savannah.nongnu.org/download/rdiff-backup/rdiff-backup-${RDIFF_VER}.tar.gz" && \
 tar xf /tmp/rdiff.tar.gz -C \
	/tmp/rdiff-src --strip-components=1 && \
 cd /tmp/rdiff-src && \
 patch -p1 -i /tmp/patches/rdiff-backup-1.2.8-librsync-1.0.0.patch && \
 python \
	setup.py build && \
 python \
	setup.py install --prefix=/usr --root=/ && \

# cleanup
 apk del --purge \
	build-dependencies && \
 rm -rf \
	/tmp/*

# copy local files
COPY root/ /

# ports and volumes
VOLUME /backup /config
