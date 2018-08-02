#!/bin/bash
patch < WWW-Curl-4.17-Skip-preprocessor-symbol-only-CURL_STRICTER.patch
perl Makefile.PL
make
make install
