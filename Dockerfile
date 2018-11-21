FROM perl:latest
MAINTAINER Michel Gokan michel@gokan.me
COPY collect_and_push.pl daemon.sh /opt/
#install-curl.sh install-curl-1.sh install-curl-1-2.sh install-curl2.sh /opt/
RUN apt-get update
RUN apt-get install -y wget curl build-essential autoconf patch libmodule-install-perl libwww-curl-perl unzip libcurl4-gnutls-dev jq
#libcurl4-openssl-dev
#RUN curl -L http://cpanmin.us | perl - App::cpanminus
RUN export PERL_MM_USE_DEFAULT=1
#RUN cpanm install WWW::Curl::Easy
RUN cd /
RUN wget https://cpan.metacpan.org/authors/id/S/SZ/SZBALINT/WWW-Curl-4.17.tar.gz -P /opt/
RUN tar -xzf /opt/WWW-Curl-4.17.tar.gz -C /opt/
#RUN export PERL5LIB=$PERL5LIB:/opt/WWW-Curl-4.17/inc
RUN wget https://rt.cpan.org/Public/Ticket/Attachment/1668211/895272/WWW-Curl-4.17-Skip-preprocessor-symbol-only-CURL_STRICTER.patch -P /opt/WWW-Curl-4.17
RUN cd /opt/WWW-Curl-4.17 && patch < WWW-Curl-4.17-Skip-preprocessor-symbol-only-CURL_STRICTER.patch
COPY curl.patch /opt/WWW-Curl-4.17/
RUN cd /opt/WWW-Curl-4.17 && patch < curl.patch
RUN find /usr | grep curl.h
RUN cd /opt/WWW-Curl-4.17 && perl Makefile.PL /usr/include/x86_64-linux-gnu/
RUN cd /opt/WWW-Curl-4.17 && make
RUN cd /opt/WWW-Curl-4.17 && make install
#RUN /opt/install-curl.sh
#RUN /opt/install-curl-1.sh
#RUN /opt/install-curl-1-2.sh
#RUN /opt/install-curl2.sh
#RUN cpan install inc::Module:Install
#RUN cpanm WWW::Curl::Easy
ENTRYPOINT /opt/daemon.sh
