(load "../nanomsg.l")

(prinl "^J  Testing Nanomsg FFI bindings for PicoLisp^J")

(symbols 'nanomsg)

(setq *My_tests_are_order_dependent NIL)

[de test-rep-bind ()
  (let (Sockpair  (rep-bind "tcp://127.0.0.1:5560")
        Result    (unit~assert-equal  '(0 . 1)
                                      Sockpair
                                      "REP-BIND socket is created") )
      (end-sock Sockpair)
      Result ]

[de test-req-connect ()
  (let (Sockpair  (req-connect "tcp://127.0.0.1:5560")
        Result    (unit~assert-equal  '(0 . 1)
                                      Sockpair
                                      "REQ-CONNECT socket is created") )
      (end-sock Sockpair)
      Result ]

[de test-pub-bind ()
  (let (Sockpair  (pub-bind "tcp://127.0.0.1:5560")
        Result    (unit~assert-equal  '(0 . 1)
                                      Sockpair
                                      "PUB-BIND socket is created") )
      (end-sock Sockpair)
      Result ]

[de test-sub-connect ()
  (let (Sockpair  (sub-connect "tcp://127.0.0.1:5560")
        Result    (unit~assert-equal  '(0 . 1)
                                      Sockpair
                                      "SUB-CONNECT socket is created") )
      (end-sock Sockpair)
      Result ]

[de test-bus-bind ()
  (let (Sockpair  (bus-bind "tcp://127.0.0.1:5560")
        Result    (unit~assert-equal  '(0 . 1)
                                      Sockpair
                                      "BUS-BIND socket is created") )
      (end-sock Sockpair)
      Result ]

[de test-bus-connect ()
  (let (Sockpair  (bus-connect "tcp://127.0.0.1:5560")
        Result    (unit~assert-equal  '(0 . 1)
                                      Sockpair
                                      "BUS-CONNECT socket is created") )
      (end-sock Sockpair)
      Result ]

[de test-pair-bind ()
  (let (Sockpair  (pair-bind "tcp://127.0.0.1:5560")
        Result    (unit~assert-equal  '(0 . 1)
                                      Sockpair
                                      "PAIR-BIND socket is created") )
      (end-sock Sockpair)
      Result ]

[de test-pair-connect ()
  (let (Sockpair  (pair-connect "tcp://127.0.0.1:5560")
        Result    (unit~assert-equal  '(0 . 1)
                                      Sockpair
                                      "PAIR-CONNECT socket is created") )
      (end-sock Sockpair)
      Result ]

[de test-pull-bind ()
  (let (Sockpair  (pull-bind "tcp://127.0.0.1:5560")
        Result    (unit~assert-equal  '(0 . 1)
                                      Sockpair
                                      "PULL-BIND socket is created") )
      (end-sock Sockpair)
      Result ]

[de test-push-connect ()
  (let (Sockpair  (push-connect "tcp://127.0.0.1:5560")
        Result    (unit~assert-equal  '(0 . 1)
                                      Sockpair
                                      "PULL-CONNECT socket is created") )
      (end-sock Sockpair)
      Result ]

[de test-survey-bind ()
  (let (Sockpair  (survey-bind "tcp://127.0.0.1:5560")
        Result    (unit~assert-equal  '(0 . 1)
                                      Sockpair
                                      "SURVEY-BIND socket is created") )
      (end-sock Sockpair)
      Result ]

[de test-respond-connect ()
  (let (Sockpair  (respond-connect "tcp://127.0.0.1:5560")
        Result    (unit~assert-equal  '(0 . 1)
                                      Sockpair
                                      "RESPOND-CONNECT socket is created") )
      (end-sock Sockpair)
      Result ]

[de test-send-recv ()
  # Fork the sender and let it block until sent
  (unless (fork)
    (let Sockpair
      (pair-bind "tcp://127.0.0.1:5561")
      (msg-send (car Sockpair) "Hello World!")
      (end-sock Sockpair) )
    (bye) )

  # Receive the message
  (let (Sockpair (pair-connect "tcp://127.0.0.1:5561")
        Result   (msg-recv (car Sockpair)))
    (end-sock Sockpair)

    (unit~assert-equal  "Hello World!"
                        Result
                        "Successfully send/receive a message using PAIR protocol" ]

[de test-protocol-bind ()
  (let (Sockpair  (protocol-bind "REP" "tcp://127.0.0.1:5560")
        Result    (unit~assert-equal  '(0 . 1)
                                      Sockpair
                                      "Protocol REP-BIND socket is created") )
      (end-sock Sockpair)
      Result ]

[de test-protocol-connect ()
  (let (Sockpair  (protocol-connect "REQ" "tcp://127.0.0.1:5560")
        Result    (unit~assert-equal  '(0 . 1)
                                      Sockpair
                                      "Protocol REQ-CONNECT socket is created") )
      (end-sock Sockpair)
      Result ]

[unit~execute
  '(unit~assert-throws  'InternalError
                        '(NanomsgError . "Protocol not supported")
                        '(rep-bind "tcpz://127.0.0.1:5560")
                        "Throw an InternalError when trying to use an invalid transport" )
  '(unit~assert-throws  'InternalError
                        '(NanomsgError . "Invalid protocol")
                        '(protocol-connect "REQ" "tcp://127.0.0.1:5560")
                        "Throw an InternalError when trying to use an invalid protocol" )

  '(test-rep-bind)
  '(test-req-connect)
  '(test-pub-bind)
  '(test-sub-connect)
  '(test-bus-bind)
  '(test-bus-connect)
  '(test-pair-bind)
  '(test-pair-connect)
  '(test-pull-bind)
  '(test-push-connect)
  '(test-survey-bind)
  '(test-respond-connect)
  '(test-send-recv)
  '(test-protocol-bind)
  '(test-protocol-connect) ]
