# PicoLisp-Nanomsg Explanation

This document is an attempt to explain some of the source code for the `PicoLisp-Nanomsg` FFI bindings.

It is not aimed at lisp experts, but rather newbies (like me), searching for tips and ideas on how to do lispy things using a [Native C Library in PicoLisp](http://software-lab.de/doc/native.html).

You can consider it more like a tutorial or walkthrough, which I'll try my best to keep updated along with the code.

# Getting started

If you haven't already, then you should check out the [README](README.md) to get an idea of what this library does.

# Explaining nanomsg.l

The `nanomsg.l` file is split into 3 major sections:

1. `ffi-bindings`: These are 1-1 function mappings with the Nanomsg C library.
2. `internal`: Functions which you should not need to use unless implementing a new 1-1 mapping or public function.
3. `public`: Functions which can be called by your application, mostly wrappers around `internal` and `ffi-bindings`.

## Start of the file

At the top of the file, we define a PicoLisp namespace, and some global variables:

### Namespaces

PicoLisp allows you to define namespaces for your functions, using [symbols](http://software-lab.de/doc/refS.html#symbols). It's similar to the concept of _Modules_ in Ruby.

```lisp
(symbols 'nanomsg 'pico)
```

Here, we create a namespace called `nanomsg` which is a copy of the `pico` (default) namespace.

Outside of this library, you can call functions by prefixing the tilde (`~`):

```lisp
(nanomsg~nn-errno)
```

Or you can switch namespace by declaring it first:

```lisp
(symbols 'nanomsg)

(nn-errno)
```

Easy.

### Global variables

The PicoLisp naming conventions expect you to declare global variables prefixed by an asterisk (`*`) and a capital letter. For constants, I think it's safe to use `ALL_CAPS`.

Let's start with the first [setq](http://software-lab.de/doc/refS.html#setq).

```lisp
(setq MSG_MAX_SIZE (if (sys "NANOMSG_MAX_SIZE") (format @) 8192))
```

This uses the [sys](http://software-lab.de/doc/refS.html#sys) function to read an environment variable. If it exists, it uses [format](http://software-lab.de/doc/refS.html#format) to convert it to a Number (environment variables will always be read as Strings). If it doesn't exist, then it assigns the Number `8192` as the value to MSG_MAX_SIZE.

> **Note:** I explicitly choose `setq` to allow you to change that value anytime you want, without setting off any warnings. Be careful when doing that though.

Next:

```lisp
(setq *Nanomsg (pack (car (file)) "lib/libnanomsg.so"))
```

Here we assign the name of the native C (shared) library (`libnanomsg.so`) to a global variable `*Nanomsg`. It makes code a bit cleaner, particularly when dealing with native C libraries.

## 1. ffi-bindings

If you plan to write an [ffi-binding](https://en.wikipedia.org/wiki/Foreign_function_interface), it's a good idea to use the same function names as the C library.

I'll only go into detail of `nn-getsockopt`, since it seems to cover most aspects about native C calls.

### nn-getsockopt

```lisp
[de nn-getsockopt (Sock Level Option &buf Length)
  (use Buf
    (cons
      (native `*Nanomsg "nn_getsockopt" 'I
                                        Sock
                                        (symbol-val Level)
                                        (symbol-val Option)
                                        (cons 'Buf &buf 0)
                                        Length )
      Buf ]
```

You'll quickly notice one of the arguments is named `&buf`. In fact this should be `*buf` to indicate a C pointer, but I didn't want to induce confusion with global variables. The idea was to make it clear the value would receive a [structure](http://software-lab.de/doc/refS.html#struct) (I'll explain this later).

The second line: `(use Buf` is something really lovely. The [use](http://software-lab.de/doc/refU.html#use) function allows you to _contain_ a variable which could become global otherwise. In the `nn-getsockopt` function, the Buf variable would have been global if it weren't for `(use`.

The first [cons](http://software-lab.de/doc/refC.html#cons) is there because we want to return the result of the `native` call as the `car`, and the `Buf` in the `cdr`.

#### Square brackets

The attentive would notice I used `]` in places as opposed to parens `)`. This is known as a [super parens](http://software-lab.de/doc/ref.html#macro-io) (the name is awesome!). It essentially closes all your parens with just one square bracket.

```lisp
(de my-func (Arg1) (cons (1 2 3) (4 5 6] # I think this is ugly, but useful
```

My personal convention is to use a super parens at the end of a multi-line expression.

```lisp
[de my-func (Arg1)
  (let Buf (cons (1 2 3)
                 (4 5 6) ] # better
```

Sometimes it's nice to use square brackets to clearly define the start and end of something.

```lisp
(de my-func (Arg1 Arg2)
  [let  Buf (cons (1 2 3)
                  (4 5 6)
        (when (something) (do-something-else)) ]
  (cleanup-everything) )
```

Perhaps it's just a matter of personal taste.


#### The native call

[Native](http://software-lab.de/doc/refN.html#native) calls can be quite confusing at first.

This call is identical to: `(native "lib/libnanomsg.so" "nn_getsockopt" ...`.

The 3rd argument to `native` is the type of result the C function returns. We expect the result to be an Integer (`I`). If your C function returns a pointer, set it to `N`. When the result is a pointer, the value can be extracted using [struct](http://software-lab.de/doc/refS.html#struct).

The next arguments are the ones expected by the C function. They can be Integers, Strings, Fixpoint numbers (cons pair) or Structures. In this case it's:

```C
int nn_getsockopt (int s, int level, int option, void *optval, size_t *optvallen);
```

The first three are Integers. We have an internal function called `symbol-val` which returns the value of the "constant" (string) specified. Example:

```lisp
: (symbol-val "NN_RCVFD")
-> 11
```

> **Note:** There's some magic behind this, because the Nanomsg C library authors created a function called `nn-symbol` which allows you to fetch every exported C constant, along with their values. That's a really brilliant and helpful feature for people writing ffi-bindings. With most C libraries, you'll need to define all the constants yourself.

The 4th is the tricky one. It's a Structure.

```lisp
(cons 'Buf &buf 0)
```

The _Structure_ argument (a C pointer) is a list which must follow a very specific format:

* a variable as the `car`. In our case we call it `Buf`. This variable will receive the result set in the pointer (also, potentially a structure).
* a cons pair which will be sent to the C function.
* An (optional) initialization value for the rest of the structure.

There are much more details available in the [native](http://software-lab.de/doc/refN.html#native) documentation.

We could have replaced the above with this:

```lisp
(cons 'Buf (8192 B . 8192) 0)
```

This would automatically create a buffer (in memory) of `8192 Bytes` (set to 0), and expect a result of `8192 Bytes` to be returned. Of course, all values which aren't filled in the result will be set to `0`.

> **Note:** What's nice about using `native` to allocate buffers is the memory is free'd once the call completes. If you use `malloc` directly, then you need to free the memory as well. There's no fun in that.

## 2. internal

I mentioned earlier the existence of a magical `nn-symbol` function. We use this to fetch all the C constants, and store them in an association list (key/value pairs).

### *NN_Symbols

```lisp
[de fetch-symbols ()
  (let (Index -1 P)
    (make
      (while (nn-symbol (inc 'Index) '(P (4 . I)))
        (link (cons @ P)) ]

(setq *NN_Symbols (fetch-symbols))
```

This `*NN_Symbols` internal global variable is created at runtime. It sets the local `Index` variable to `-1`, and the local `P` variable to `NIL` (no value = NIL).

It then uses [make](http://software-lab.de/doc/refM.html#make) and [link](http://software-lab.de/doc/refL.html#link) to generate a list from the result of the [while](http://software-lab.de/doc/refW.html#while) loop.

The `while` loop calls `nn-symbol` by using [inc](http://software-lab.de/doc/refI.html#inc) to increment the `Index` by `1`. The second argument to `nn-symbol` is a _Structure_ as we've seen earlier, which is really just one Integer of 4 Bytes.

What's interesting is the way this magic function works. It returns the name of the constant (ex: `"NN_RCVFD"`), but it sets the value of the constant in the buffer, which we assign to the variable `P` (ex: `11`).

We create a `cons` pair using the [@ result](http://software-lab.de/doc/ref.html#atres) as the `car`, and the `P` result as the `cdr`. In this case, the `@` result refers to the value returned by the `nn-symbol` call.

> **Note:** In English, this means `P` will contain a 4-byte Integer (value) and `@` will contain the constant's name.

If the `nn-symbol` call returns `NIL`, then we've reached the end of the list of constants, so the `while` loop exits, and our `*NN_Symbols` variable is fully set:

Here is a truncated `*NN_Symbols` list from nanomsg 0.7-beta:

```lisp

(("NN_NS_NAMESPACE" . 0) ("NN_NS_VERSION" . 1) ("NN_NS_DOMAIN" . 2) ("NN_NS_TRANSPORT" . 3) ("NN_NS_PROTOCOL" . 4) ("NN_NS_OPTION_LEVEL" . 5) ("NN_NS_SOCKET_OPTION" . 6)
```

Cool.

### symbol-val

This function is quite simple. It fetches the `cdr` (the value) of the constant by it's name, by searching through the association list.

```lisp
(de symbol-val (Symbol)
  (cdr (assoc Symbol *NN_Symbols)) )
```

### exit-with-error

There's nothing special about this function. I simply wanted to highlight the [throw](http://software-lab.de/doc/refT.html#throw) call, which stops the execution and returns a cons pair (error):

```lisp
(de exit-with-error (Sock Endpoint)
  (when (and Endpoint (ge0 Endpoint)) (nn-shutdown Sock Endpoint))
  (when Sock (nn-close Sock))
  (throw 'InternalError (cons 'NanomsgError (nn-strerror (nn-errno))) ) )
```

This can be caught with `(catch 'InternalError`. The return value is a list which will contain `'NanomsgError` in the `car`, and a String in the `cdr`.

### create-socket

I won't go into detail about the `create-socket` internal function, but I was pleased to discover the [default](http://software-lab.de/doc/refD.html#default) function, which assigns a default value to a variable.

```lisp
[de create-socket (Type Domain)
  (default Domain "AF_SP")
```

In this case, we assign the default value `"AF_SP"` to the variable `Domain` which is sent as an argument to the function. If `Domain` is set (non-NIL), then its value is not re-assigned.

### non-blocking-io

Sometimes you want to do something, sometimes you don't. That's a binary decision (0 or 1), and functions which return a true/false'ish type of result are called predicates. [bool](http://software-lab.de/doc/refB.html#bool) is a nice predicate which returns `T` if the value is set.

```lisp
(de non-blocking-io (Dontwait)
   (when (bool Dontwait) (symbol-val "NN_DONTWAIT")) )
```

In this call, we want to return the value of the constant `NN_DONTWAIT`, but only if the `Dontwait` argument is set. Otherwise it returns `NIL`. This is kind of a hack, since it can be set to anything and it will always return the value of the constant.

There might be a better way to do this.

## 3. public

We've defined quite a few public functions which can be called from outside the library. Nanomsg doesn't provide these, so we made them in order to make your life easier. Instead of interacting directly with the `native` function calls, you can use a simple _public function_ and move on with your life.

I'll only explain the `msg-recv` function, since it does some pretty cool stuff.

### msg-recv

This function can be called in blocking or non-blocking mode. It will listen on a socket and wait for a message to arrive.

```lisp
[de msg-recv (Sock Dontwait)
  (let Result (nn-recv Sock '(`MSG_MAX_SIZE B . `MSG_MAX_SIZE) MSG_MAX_SIZE (non-blocking-io Dontwait) )
    (unless (exit-with-error-maybe Dontwait Result Sock)
      (pack (mapcar char (head (car Result) (cdr Result)))) ]
```

The first thing you'll notice is this crazy argument sent to `nn-recv`. It's something we saw earlier: `'(8192 B . 8192)`. The reason we use the [backtick](http://software-lab.de/doc/refB.html#bool) (backquote) is to immediately evaluate the expression. You'll notice the list is quoted with a [single quote](http://software-lab.de/doc/refQ.html#quote) for an unevaluated expression, but in fact we want to evaluate that `MSG_MAX_SIZE` constant right away (turn it into `8192`).

The next line will essentially exit the application depending on the result of the `nn-recv` call and the value of the `Dontwait` variable.

The meat is here:

```lisp
(pack (mapcar char (head (car Result) (cdr Result))))
```

As you know, [cdr](http://software-lab.de/doc/refC.html#cdr) returns the result of the list (everything after the 1st element). And [car](http://software-lab.de/doc/refC.html#car) returns the 1st element of the list.

When you pass these to [head](http://software-lab.de/doc/refH.html#head), it will return only the first N elements (first argument) of the list (2nd argument).

For example:

```lisp
(setq Result (12 104 101 108 108 111 0 0 8 0 0 0 0 0 0 0))
-> (12 104 101 108 108 111 0 0 8 0 0 0 0 0 0 0)
: (head (car Result) (cdr Result))
-> (104 101 108 108 111 0 0 8 0 0 0 0)
```

Here we fetched the first `12` elements of the list.

If you didn't know, [char](http://software-lab.de/doc/refC.html#char) will return a Unicode character when you pass a Number as the argument.

The use of [mapcar](http://software-lab.de/doc/refM.html#mapcar) is to iterate over the list, with the `char` function -- essentially calling `char` on every element in the list.

The [pack](http://software-lab.de/doc/refP.html#pack) function will remove all NIL values from the list. If you try to `(char 0)` you'll see it returns NIL.

```lisp
: (pack (mapcar char (head (car Result) (cdr Result))))
-> "hello^H"
```

> **Note:** What this means is it receives the 8K buffer which contains a bunch of zeros at the end (assuming you didn't fill the buffer), it maps over the list, sets the zeros to NIL, packs it and you end up with a nice friendly string.

This might also be a huge hack, but I thought it was cool and functional. Very open to suggestions on how to improve it.

# The end

That's pretty much all I have to explain about the Nanomsg FFI binding. I'm very open to providing more details about functionality I've skipped, so just file an [issue](https://github.com/aw/picolisp-nanomsg/issues/new) and I'll do my best.

# License

This work is licensed under a [Creative Commons Attribution-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-sa/4.0/).

Copyright (c) 2015 Alexander Williams, Unscramble <license@unscramble.jp>
