# Changelog

## 0.5.24 (2014-04-14)

  * Update to picolisp-unit v0.6.1
  * Run travis-ci tests in a docker container

## 0.5.23 (2014-04-08)

  * Split the 'make-socket' function to allow pooled connections
  * Ensure travis tests with the latest version of PicoLisp

## 0.5.22 (2014-04-07)

  * Update to picolisp-unit v0.6.0
  * Ignore dirty submodules

## 0.5.21 (2014-04-01)

  * Update to picolisp-unit v0.5.2

## 0.5.20 (2014-03-24)

  * Add test for sending/receiving messages

## 0.5.19 (2014-03-24)

  * Swap order of module.l loading

## 0.5.18 (2014-03-24)

  * Don't forget to load module.l

## 0.5.17 (2015-03-24)

  * Add test-suite for the SP protocols
  * Add .travis.yml for automated build testing
  * Update README.md and EXPLAIN.md
  * Close the socket and endpoint when an error is thrown
  * Move MODULE_INFO to module.l

## 0.5.16 (2015-03-15)

  * Ensure the lib is loaded relative to nanomsg.l

## 0.5.15 (2015-03-12)

  * Throw an `'InternalError` error when it occurs, instead of quitting.
