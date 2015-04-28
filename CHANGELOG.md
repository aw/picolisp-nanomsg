# Changelog

## 0.5.27 (2015-04-28)

  * Remove the need for git submodules
  * Add Makefile for fetching and building dependencies
  * Change default path for dependencies and shared module (.modules and .lib)
  * Adjust README.md, tests and travis-ci unit testing config

## 0.5.26 (2015-04-23)

  * Replace (cond) with (case)

## 0.5.25 (2015-04-15)

  * Split 'make-socket' for more flexibility
  * Update EXPLAIN.md

## 0.5.24 (2015-04-14)

  * Update to picolisp-unit v0.6.1
  * Run travis-ci tests in a docker container

## 0.5.23 (2015-04-08)

  * Split the 'make-socket' function to allow pooled connections
  * Ensure travis tests with the latest version of PicoLisp

## 0.5.22 (2015-04-07)

  * Update to picolisp-unit v0.6.0
  * Ignore dirty submodules

## 0.5.21 (2015-04-01)

  * Update to picolisp-unit v0.5.2

## 0.5.20 (2015-03-24)

  * Add test for sending/receiving messages

## 0.5.19 (2015-03-24)

  * Swap order of module.l loading

## 0.5.18 (2015-03-24)

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
