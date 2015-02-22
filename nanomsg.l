# Copyright (c) 2015 Alexander Williams, Unscramble <license@unscramble.jp>
# MIT License
#
# Nanomsg ffi-binding for PicoLisp

(symbols 'nanomsg 'pico)

(setq
  MSG_MAX_SIZE (if (sys "NANOMSG_MAX_SIZE") (format @) 8192) # 8KB should be enough

  *Nanomsg "lib/libnanomsg.so" )

# ffi-bindings
(de nn-socket (Domain Protocol)
  (native `*Nanomsg "nn_socket" 'I (symbol-val Domain) (symbol-val Protocol)) )

(de nn-close (Sock)
  (native `*Nanomsg "nn_close" 'I Sock) )

(de nn-setsockopt (Sock Level Option Optval Length)
  (native `*Nanomsg "nn_setsockopt" 'I Sock Level Option Optval Length) )

(de nn-bind (Sock Addr)
  (native `*Nanomsg "nn_bind" 'I Sock Addr) )

(de nn-connect (Sock Addr)
  (native `*Nanomsg "nn_connect" 'I Sock Addr) )

(de nn-shutdown (Sock Endpoint)
  (native `*Nanomsg "nn_shutdown" 'I Sock Endpoint) )

(de nn-send (Sock Msg Length Flags)
  (native `*Nanomsg "nn_send" 'I Sock Msg Length Flags) )

# returns the number of bytes in 'car', msg in 'cdr'
(de nn-recv (Sock &buf Length Flags)
  (use Buf
    (cons (native `*Nanomsg "nn_recv" 'I Sock (list 'Buf &buf . 0) Length Flags) Buf) ) )

(de nn-errno ()
  (native `*Nanomsg "nn_errno" 'I) )

(de nn-strerror (Errnum)
  (native `*Nanomsg "nn_strerror" 'S Errnum) )

(de nn-symbol (Index &value)
  (native `*Nanomsg "nn_symbol" 'S Index &value) )

# internal
[setq NN_Symbols
  (let (Index -1 P)
    (make
      (while (nn-symbol (inc 'Index) '(P (4 . I)))
        (link (cons @ P)) ]

(de symbol-val (Symbol)
  (cdr (assoc Symbol NN_Symbols)) )

(de exit-with-error ()
  (let Error (nn-strerror (nn-errno)) (prinl "ERROR: " Error) (bye 1)) )

[de req-rep (Addr Type)
  (let Sock (nn-socket "AF_SP" Type)
    (if (= -1 Sock)
        (exit-with-error)
        (let Endpoint
          (cond ((= Type "NN_REP") (nn-bind Sock Addr))
                ((= Type "NN_REQ") (nn-connect Sock Addr)) )
          (cond ((not Endpoint)  (exit-with-error))
                ((= -1 Endpoint) (exit-with-error)) )
          (cons Sock Endpoint) ]

# public
(de rep-bind (Addr)
  (req-rep Addr "NN_REP") )

(de req-connect (Addr)
  (req-rep Addr "NN_REQ") )

[de end-sock (Sockpair)
  (nn-shutdown (car Sockpair) (cdr Sockpair))
  (nn-close (car Sockpair)) ]

[de msg-recv (Sock)
  (let Result (nn-recv Sock '(`MSG_MAX_SIZE B . `MSG_MAX_SIZE) MSG_MAX_SIZE 0)
    (if (= -1 (car Result))
        (exit-with-error)
        (pack (mapcar char (cdr Result))) ]

[de msg-send (Sock Msg)
  (let Result (nn-send Sock Msg (size Msg) 0)
    (when (= -1 Result) (exit-with-error)) ]
