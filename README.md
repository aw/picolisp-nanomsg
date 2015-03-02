# PicoLisp-Nanomsg FFI Binding

[Nanomsg](http://nanomsg.org/index.html) FFI binding for [PicoLisp](http://picolisp.com/).

**WARNING:** This binding, like Nanomsg, is in beta and supports the following protocols:

  * `REQ/REP`
  * `PUB/SUB`
  * `PAIR`
  * `PUSH/PULL (PIPELINE)`
  * `SURVEY`

# Version

**v0.5.9** (uses Nanomsg _v0.5_)

# Requirements

  * PicoLisp 64-bit v3.1.9+
  * Git
  * UNIX/Linux development/build tools (gcc, make/gmake, etc..)

# Getting started

This binding relies on the _Official Nanomsg C Library_, compiled as a shared library. It is included here as a [git submodule](http://git-scm.com/book/en/v2/Git-Tools-Submodules).

  1. Type `./build.sh` to pull and compile the _Official Nanomsg C Library_.
  2. Include `nanomsg.l` in your project
  3. Try the example below

## Linking and Paths

Once compiled, the shared library is symlinked in `lib/libnanomsg.so` pointing to `vendor/nanomsg/.libs/libnanomsg.so`.

The `nanomsg.l` file searches for `lib/libnanomsg.so`, relative to its current directory.

# Usage

All functions are publicly accessible and namespaced with `(symbols 'nanomsg)` (or the prefix: `nanomsg~`), but only the following are necessary:

  * `rep-bind`: bind a `REP` socket (inproc, ipc, tcp)
  * `req-connect`: connect to a `REQ` socket (inproc, ipc, tcp)
  * `pub-bind`: bind to a `PUB` socket (inproc, ipc, tcp)
  * `sub-connect`: connect to a `SUB` socket (inproc, ipc, tcp)
  * `end-sock`: shutdown and close a socket
  * `msg-recv`: receive a message (blocking/non-blocking)
  * `msg-send`: send a message (blocking/non-blocking)
  * `subscribe`: subscribe to a `PUB/SUB` topic
  * `unsubscribe`: unsubscribe from a `PUB/SUB` topic
  * `pair-bind`: bind to a `PAIR` socket (inproc, ipc, tcp)
  * `pair-connect`: connect to a `PAIR` socket (inproc, ipc, tcp)
  * `pull-bind`: bind to a `PULL` socket (inproc, ipc, tcp)
  * `push-connect`: connect to a `PUSH` socket (inproc, ipc, tcp)
  * `survey-bind`: bind to a `SURVEY` socket (inproc, ipc, tcp)
  * `respond-connect`: connect to a `SURVEY` socket (inproc, ipc, tcp)

# Example (REQ/REP)

## Server

```lisp
pil +
(load "nanomsg.l")

(symbols 'nanomsg)
(unless (fork)
  (let Sockpair
    (rep-bind "tcp://127.0.0.1:5560")

    (prinl (msg-recv (car Sockpair)))
    (msg-send (car Sockpair) "Yep I can see it!" T) # non-blocking

    (end-sock Sockpair) )

  (bye) )

# => Can you see this?
```

## Client

```lisp
pil +
(load "nanomsg.l")

(symbols 'nanomsg)
(unless (fork)
  (let Sockpair
    (req-connect "tcp://127.0.0.1:5560")
    (msg-send (car Sockpair) "Can you see this?")
    (prinl (msg-recv (car Sockpair)))
    (end-sock Sockpair) )
  (bye) )

# => Yep I can see it!
```

# Example (PUB/SUB)

## Server

```lisp
pil +
(load "nanomsg.lo")

(symbols 'nanomsg)
(unless (fork)
  (let Sockpair
    (sub-connect "tcp://127.0.0.1:5560")
    (subscribe (car Sockpair) "test")
    (while T (prinl "RECEIVED: " (msg-recv (car Sockpair))) (wait 1000 (unsubscribe 0 "test")))
    (end-sock Sockpair) )
  (bye) )

# => RECEIVED: test Hello World!
```

## Client

```lisp
pil +
(load "nanomsg.l")

(let Sockpair
  (pub-bind "tcp://127.0.0.1:5560")
  (while T (msg-send (car Sockpair) "test Hello World!"))
  (end-sock Sockpair) )
```

# Example (PAIR)

## Server

```lisp
pil +
(load "nanomsg.l")

(symbols 'nanomsg)
(unless (fork)
  (let Sockpair
    (pair-connect "tcp://127.0.0.1:5560")
    (prinl (msg-recv (car Sockpair)))
    (end-sock Sockpair) )
  (bye) )

# => Hello World!
```

## Client

```lisp
pil +
(load "nanomsg.l")

(symbols 'nanomsg)
(unless (fork)
  (let Sockpair
    (pair-bind "tcp://127.0.0.1:5560")
    (prinl (msg-send (car Sockpair) "Hello World!"))
    (end-sock Sockpair) )
  (bye) )
```

# Example (PUSH/PULL) - PIPELINE

## Server

```lisp
pil +
(load "nanomsg.l")

(symbols 'nanomsg)
(unless (fork)
  (let Sockpair
    (pull-bind "tcp://127.0.0.1:5560")
    (prinl (msg-recv (car Sockpair)))
    (end-sock Sockpair) )
  (bye) )

# => Hello Pipeline
```

## Client

```lisp
pil +
(load "nanomsg.l")

(symbols 'nanomsg)
(unless (fork)
  (let Sockpair
    (push-connect "tcp://127.0.0.1:5560")
    (prinl (msg-send (car Sockpair) "Hello Pipeline"))
    (end-sock Sockpair) )
  (bye) )
```

# Example (SURVEY)

## Server

```lisp
pil +
(load "nanomsg.l")

(symbols 'nanomsg)
(unless (fork)
  (let Sockpair (survey-bind "tcp://127.0.0.1:5560")
    (msg-send (car Sockpair) "Knock knock.")
    (prinl (msg-recv (car Sockpair)))
    (end-sock Sockpair) )
  (bye) )

# => Who's there?
```

## Client

```lisp
pil +
(load "nanomsg.l")

(symbols 'nanomsg)
(unless (fork)
  (let Sockpair
    (respond-connect "tcp://127.0.0.1:5560")
    (prinl (msg-recv (car Sockpair)))
    (msg-send (car Sockpair) "Who's there?")
    (end-sock Sockpair) )
  (bye) )

# => Knock knock.
```

# Non-blocking I/O

Some situations require non-blocking I/O. You can call `msg-recv` or `msg-send` with a last argument `T` to enable non-blocking mode. Be aware `NIL` will be returned if `EAGAIN` is received during a non-blocking call. You need to manually poll/loop over the socket in this situation.

Usage example:

```lisp
...
(let Msg (msg-recv (car Sockpair) T)
  (when Msg (fifo '*Messages Msg)) )
...
```

# Receive buffer size

A fixed amount of memory is allocated for each receive buffer. The default setting is `8192` Bytes (8 KiB).

This can be changed with the environment variable `NANOMSG_MAX_SIZE`. You can also overwrite the `MSG_MAX_SIZE` global constant at runtime.

# TODO:

  * Implement missing protocol (bus)

# Contributing

If you find any bugs or issues, please [create an issue](https://github.com/aw/picolisp-nanomsg/issues/new).

If you want to improve this library, please make a pull-request.

# License

[MIT License](LICENSE)
Copyright (c) 2015 Alexander Williams, Unscramble <license@unscramble.jp>
