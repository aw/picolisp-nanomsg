# PicoLisp-Nanomsg FFI Binding

[Nanomsg](http://nanomsg.org/index.html) FFI binding for [PicoLisp](http://picolisp.com/).

**WARNING:** This binding, like Nanomsg, is in beta and currently only supports the `REQ/REP` protocols.

# Version

**v0.5.1** (uses Nanomsg _v0.5_)

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

All functions are publicly accessible and prefixed with `nanomsg~`, but only the following are necessary:

  * `rep-bind`: bind a `REP` socket (inproc, ipc, tcp)
  * `req-connect`: connect to a `REQ` socket (inproc, ipc, tcp)
  * `end-sock`: shutdown and close a socket
  * `msg-recv`: receive a message
  * `msg-send`: send a message

# Example (REQ/REP)

## Server

```lisp
pil +
(load "nanomsg.l")

(unless (fork)
  (let Sockpair
    (nanomsg~rep-bind "tcp://127.0.0.1:5560")
    (prinl (nanomsg~msg-recv (car Sockpair)))
    (nanomsg~msg-send (car Sockpair) "Yep I can see it!")
    (nanomsg~end-sock Sockpair) )
  (bye) )

=> Can you see this?
```

## Client

```lisp
pil +
(load "nanomsg.l")

(unless (fork)
  (let Sockpair
    (nanomsg~req-connect "tcp://127.0.0.1:5560")
    (nanomsg~msg-send (car Sockpair) "Can you see this?")
    (prinl (nanomsg~msg-recv (car Sockpair)))
    (nanomsg~end-sock Sockpair) )
  (bye) )

=> Yep I can see it!
```

# Receive buffer size

A fixed amount of memory is allocated for each receive buffer. The default setting is `8192` Bytes (8 KiB).

This can be changed with the environment variable `NANOMSG_MAX_SIZE`. You can also overwrite the `MSG_MAX_SIZE` global constant at runtime.

# TODO:

  * Implement missing protocols (pub/sub, survey, push/pull, pair)

# Contributing

If you find any bugs or issues, please [create an issue](https://github.com/aw/picolisp-nanomsg/issues/new).

If you want to improve this library, please make a pull-request.

# License

[MIT License](LICENSE)
Copyright (c) 2015 Alexander Williams, Unscramble <license@unscramble.jp>
