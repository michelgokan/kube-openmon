FROM perl:latest
MAINTAINER Michel Gokan michel@gokan.me
COPY collect_and_push.pl daemon.sh /opt/
RUN apt-get update
RUN apt-get install -y wget curl build-essential libwww-curl-perl libcurl4-openssl-dev unzip 
#RUN curl -L http://cpanmin.us | perl - App::cpanminus
RUN export PERL_MM_USE_DEFAULT=1
RUN install-curl.sh
#RUN cpan install inc::Module:Install
#RUN cpanm WWW::Curl::Easy
ENTRYPOINT /opt/daemon.sh
