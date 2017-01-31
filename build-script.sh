#!/bin/bash

export RUNTIME_PACKAGES="wget libxml2 libxslt1.1 curl zip openssl libgd-dev libfcgi0ldbl  	\
libgdal1h libgeos-3.4.2 libgeos-c1 libcgal10 apache2 gdal-bin \
libmozjs185-1.0 libproj0 libgeotiff2 libcairo2 librsvg2-2 libjpeg62-turbo libtiff5 libpng3 libxslt1.1 \
python2.7 python-tk libwxbase3.0-0 libwxgtk3.0-0 wx-common apache2 openjdk-7-jdk"

apt-get update -y \
      && apt-get install -y --no-install-recommends $RUNTIME_PACKAGES

export BUILD_PACKAGES="autoconf automake autotools-dev libtool bison build-essential flex \
libwxbase3.0-dev libcairo2-dev libfcgi-dev libfreetype6-dev libgd-perl libcurlpp-dev \
libgd2-xpm-dev libgdal-dev libgeotiff-dev swig2.0 cmake libmozjs185-dev libproj-dev \
libtiff5-dev libtool libwxgtk3.0-dev libxml2-dev libxslt1-dev python-dev python-pip \
software-properties-common subversion unzip wx3.0-headers wx3.0-i18n libcgal-dev librsvg2-dev"

apt-get install -y --no-install-recommends $BUILD_PACKAGES

# for mapserver
export CMAKE_C_FLAGS=-fPIC
export CMAKE_CXX_FLAGS=-fPIC

# useful declarations
export BUILD_ROOT=/opt/build
export ZOO_BUILD_DIR=/opt/build/zoo-project
export CGI_DIR=/usr/lib/cgi-bin
export CGI_DATA_DIR=$CGI_DIR/data
export CGI_TMP_DIR=$CGI_DATA_DIR/tmp
export CGI_CACHE_DIR=$CGI_DATA_DIR/cache
export WWW_DIR=/var/www/html

# JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64

mkdir -p $BUILD_ROOT \
  && mkdir -p $CGI_DIR \
  && mkdir -p $CGI_DATA_DIR \
  && mkdir -p $CGI_TMP_DIR \
  && mkdir -p $CGI_CACHE_DIR \
  && ln -s /usr/lib/x86_64-linux-gnu /usr/lib64 || exit 1

# WITH_PROJ, WITH_WMS, WITH_FRIBIDI, WITH_HARFBUFF, WITH_ICONV, WITH_CAIRO, WITH_FCGI,
# WITH_GEOS, WITH_POSTGIS, WITH_GDAL, WITH_OGR, WITH_WFS, WITH_WCS, WITH_LIBXML2, WITH_GIF
wget -nv -O $BUILD_ROOT/mapserver-7.0.4.tar.gz http://download.osgeo.org/mapserver/mapserver-7.0.4.tar.gz \
  && cd $BUILD_ROOT/ && tar -xzf mapserver-7.0.4.tar.gz \
  && cd $BUILD_ROOT/mapserver-7.0.4 \
  && mkdir build && cd build \
  && cmake -DCMAKE_INSTALL_PREFIX=/usr \
      -DCMAKE_PREFIX_PATH=/usr/local:/opt \
      -DWITH_PROJ=ON \
      -DWITH_GEOS=ON \
      -DWITH_GDAL=ON \
      -DWITH_CURL=ON \
      -DWITH_SOS=ON \
      -DWITH_WMS=ON \
      -DWITH_WFS=ON \
      -DWITH_WCS=ON \
      -DWITH_JAVA=OFF \
      -DWITH_PYTHON=ON \
      -DWITH_SVGCAIRO=OFF \
      -DWITH_RSVG=ON \
      -DWITH_LIBXML2=ON \
      -DWITH_HARFBUZZ=OFF \
      -DWITH_FRIBIDI=OFF \
      ../ >../configure.out.txt \
      && make && make install && ln -s /usr/bin/mapserv $CGI_DIR || exit 1


# here are the thirds
ln -s /usr/lib/libfcgi.so.0.0.0 /usr/lib64/libfcgi.so \
  && ln -s /usr/lib/libfcgi++.so.0.0.0 /usr/lib64/libfcgi++.so

svn checkout http://svn.zoo-project.org/svn/trunk/thirds/ $BUILD_ROOT/thirds \
  && cd $BUILD_ROOT/thirds/cgic206 && make || exit 1

pip install numpy || exit 1

svn checkout http://svn.zoo-project.org/svn/trunk/zoo-project/ $ZOO_BUILD_DIR \
  && cd $ZOO_BUILD_DIR/zoo-kernel && autoconf \
  && ./configure --with-cgi-dir=$CGI_DIR \
  --prefix=/usr \
  --exec-prefix=/usr \
  --with-fastcgi=/usr \
  --with-gdal-config=/usr/bin/gdal-config \
  --with-geosconfig=/usr/bin/geos-config \
  --with-python \
  --with-mapserver=/usr/include/mapserver \
  --with-xml2config=/usr/bin/xml2-config \
  --with-pyvers=2.7 \
  --with-js=/usr \
   --with-java=$JAVA_HOME \
  && make && make install \
  && cp /usr/com/zoo-project/symbols.sym $CGI_DATA_DIR || exit 1

cd $ZOO_BUILD_DIR/zoo-api/java/ \
  && make && cp libZOO.so $CGI_DIR || exit 1

apt-get remove --purge -y $BUILD_PACKAGES \
  && rm -rf /var/lib/apt/lists/*

# delay until final zoo-project build
rm $BUILD_ROOT/mapserver-7.0.4.tar.gz
rm $BUILD_ROOT/mapserver-7.0.4
rm -rf $ZOO_BUILD_DIR
