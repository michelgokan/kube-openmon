FROM perl:latest
MAINTAINER Michel Gokan michel@gokan.me
COPY collect_and_push.pl daemon.sh /opt/
RUN apt-get update
RUN apt-get install -y curl build-essential libwww-curl-perl libcurl4-openssl-dev unzip 
#RUN curl -L http://cpanmin.us | perl - App::cpanminus
RUN export PERL_MM_USE_DEFAULT=1
RUN wget https://cpan.metacpan.org/authors/id/S/SZ/SZBALINT/WWW-Curl-4.17.tar.gz
RUN tar -xzf WWW-Curl-4.17.tar.gz
RUN cd WWW-Curl-4.17
RUN wget https://rt.cpan.org/Public/Ticket/Attachment/1668211/895272/WWW-Curl-4.17-Skip-preprocessor-symbol-only-CURL_STRICTER.patch
RUN patch < WWW-Curl-4.17-Skip-preprocessor-symbol-only-CURL_STRICTER.patch
RUN perl Makefile.PL
RUN make
RUN make install

#RUN cpan install inc::Module:Install
#RUN cpanm WWW::Curl::Easy
ENTRYPOINT /opt/daemon.sh
