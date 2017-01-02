# CHANGELOG for klarna-client-ruby
You should follow the [keepachangelog](http://keepachangelog.com/) format - basically, copy+paste :)

## 4.1.0 (2016-09-01)
* [Vladimir Krle] - Added support for `Extend Invoice Due Date` method 
                    Added support for `Order Info` method
                    Added support for `Invoice Lookup` method
                    Bumped Kred api_version to 4.2

## 4.0.0 (2016-12-07)
* [Or Goldfus] - Change logging format from string to hash.
                 Remove redundant logs.

## 3.1.0 (2016-09-25)
* [Chanan Damboritz] - Adds estore_id, store_name and faultCode to instrumentation data

## 3.0.1 (2016-05-04)
* [Case Taintor] - removes klarna gem tagger

## 3.0.0 (2016-04-26)
* [Chanan Damboritz] - Adds RuntimeError with the message 'HTTP-Error: 503 Service Unavailable' to retryable errors.
                       Client now raises original error when retries exhaust.

## 2.2.0 (2016-03-14)
* [Hagai Levin] - Add system readiness checker.

## 2.1.0 (2016-03-08)
* [Talya Stern] - Adds response values to instrumentation.

## 2.0.1 (2016-02-24)
* [Chanan Damboritz] - Fixes default number of retries from 2 to 3.
                       Improves logging and adds log about total number of attempts made.

## 2.0.0 (2016-02-14)
* [Chanan Damboritz] - Adds retryable errors to xmlrpc calls. These are not errors concerning an issue with the request, but rather with connectivity and retrying has no affect on the result of the request.
                       Client will now retry any calls that fail with:
                       RuntimeError with the message 'HTTP-Error: 500 Internal Server Error',
                       Net::OpenTimeout with the message 'execution expired',
                       XMLRPC::FaultException with a faultCode of 9119 or 9191 (See https://developers.klarna.com/en/se+php/kpm/error-codes for a list of error codes),
                       EOFError, ::Errno::ECONNRESET.
                       Furthermore, due to a bug in Ruby's OpenSSL implementation (See https://bugs.ruby-lang.org/issues/7215 for more details) each request is preceded by clearing any existing OpenSSL errors.

## 1.2.1 (2015-11-25)
* [Case Taintor] - Adds a bunch of constants to avoid 'magic strings' (or, integers). See `lib/klarna/constants.rb` for list.
* [Case Taintor] - Fixes bug where, if your port was a string, 'ssl' wouldn't be set.
* [Case Taintor] - Changes `Content-type` and `Accept-charset` headers to be more explicit about UTF-8. We were
                   never sending iso-8859-1 and it appears that FRED/KRED was ignoring the charset completely
                   and instead assuming UTF-8. It seems more appropriate to set our headers to be correct.
* [Case Taintor] - Fixes tests to have all their setup, so it's possible to delete the VCRs and re-record.
* [Case Taintor] - Removed redundant tests from client_spec.

## 1.2.0 (2015-11-11)
* [Case Taintor] - adds `ActiveSupport::Notifications` support. Enable by adding `use_instrumnetation!` to your config. Requires ActiveSupport.
