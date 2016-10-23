#!/bin/bash

test_110_network () {
    assert_raises 'url_exists "http://www.google.com"' 0
    assert 'url_http_response "http://www.google.com"' "200 OK"
    assert 'url_http_response_code "http://www.google.com"' "200"

    assert_end "${BASH_SOURCE[0]##*/}"
}

