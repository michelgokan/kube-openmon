FROM perl:latest
MAINTAINER Michel Gokan michel@gokan.me
COPY collect_and_push.pl daemon.sh /opt/
#install-curl.sh install-curl-1.sh install-curl-1-2.sh install-curl2.sh /opt/
RUN apt-get update
RUN apt-get install -y wget curl build-essential autoconf patch libwww-curl-perl libcurl4-openssl-dev unzip 
#RUN curl -L http://cpanmin.us | perl - App::cpanminus
RUN export PERL_MM_USE_DEFAULT=1
RUN cpan install Module::Install
RUN cd /
RUN wget https://cpan.metacpan.org/authors/id/S/SZ/SZBALINT/WWW-Curl-4.17.tar.gz -P /opt/
RUN tar -xzf /opt/WWW-Curl-4.17.tar.gz -C /opt/
RUN wget https://rt.cpan.org/Public/Ticket/Attachment/1668211/895272/WWW-Curl-4.17-Skip-preprocessor-symbol-only-CURL_STRICTER.patch -P /opt/WWW-Curl-4.17
RUN cd /opt/WWW-Curl-4.17 && patch < WWW-Curl-4.17-Skip-preprocessor-symbol-only-CURL_STRICTER.patch
RUN perl /opt/WWW-Curl-4.17/Makefile.PL
RUN cd /opt/WWW-Curl-4.17 && make
RUN cd /opt/WWW-Curl-4.17 && make install
#RUN /opt/install-curl.sh
#RUN /opt/install-curl-1.sh
#RUN /opt/install-curl-1-2.sh
#RUN /opt/install-curl2.sh
#RUN cpan install inc::Module:Install
#RUN cpanm WWW::Curl::Easy
ENTRYPOINT /opt/daemon.sh
