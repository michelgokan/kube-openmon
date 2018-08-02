FROM perl:latest
MAINTAINER Michel Gokan michel@gokan.me
RUN curl -L http://cpanmin.us | perl - App::cpanminus
COPY collect_and_push.pl daemon.sh /opt/
RUN cpanm WWW::Curl::Easy
RUN /opt/daemon.sh
