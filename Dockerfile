FROM ubuntu:18.04
COPY collect_and_push.pl daemon.sh /opt/
CMD cpan install WWW::Curl::Easy
CMD /opt/daemon.sh
