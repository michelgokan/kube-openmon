FROM perl:latest
MAINTAINER Michel Gokan michel@gokan.me
COPY collect_and_push.pl daemon.sh /opt/
RUN apt-get update
RUN apt-get install -y build-essential libwww-curl-perl
RUN curl -L http://cpanmin.us | perl - App::cpanminus
RUN cpanm WWW::Curl::Easy
RUN /opt/daemon.sh
