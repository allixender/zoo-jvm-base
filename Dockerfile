# FROM openjdk:8-jdk
FROM debian:jessie

# that's me!
MAINTAINER Alex K, allixender@googlemail.com

ENV CGI_DIR /usr/lib/cgi-bin
ENV CGI_DATA_DIR /usr/lib/cgi-bin/data
ENV CGI_TMP_DIR /usr/lib/cgi-bin/data/tmp
ENV CGI_CACHE_DIR /usr/lib/cgi-bin/data/cache
ENV WWW_DIR /var/www/html

ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64

ADD build-script.sh /opt
RUN chmod +x /opt/build-script.sh \
  && sync \
  && /opt/build-script.sh
