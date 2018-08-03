#!/bin/bash
cd /
wget https://cpan.metacpan.org/authors/id/S/SZ/SZBALINT/WWW-Curl-4.17.tar.gz
tar -xzf WWW-Curl-4.17.tar.gz
cd WWW-Curl-4.17
wget https://rt.cpan.org/Public/Ticket/Attachment/1668211/895272/WWW-Curl-4.17-Skip-preprocessor-symbol-only-CURL_STRICTER.patch
patch < WWW-Curl-4.17-Skip-preprocessor-symbol-only-CURL_STRICTER.patch
perl Makefile.PL
make
make install
