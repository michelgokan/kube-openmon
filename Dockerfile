FROM perl:latest
MAINTAINER Michel Gokan michel@gokan.me
COPY collect_and_push.pl daemon.sh install-curl.sh install-curl-1.sh install-curl-1-2.sh install-curl2.sh /opt/
RUN apt-get update
RUN apt-get install -y wget curl build-essential autoconf patch libwww-curl-perl libcurl4-openssl-dev unzip 
#RUN curl -L http://cpanmin.us | perl - App::cpanminus
RUN export PERL_MM_USE_DEFAULT=1
RUN install-curl.sh
RUN install-curl-1.sh
RUN install-curl-1-2.sh
RUN install-curl2.sh
#RUN cpan install inc::Module:Install
#RUN cpanm WWW::Curl::Easy
ENTRYPOINT /opt/daemon.sh
