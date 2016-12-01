;; A Backend-as-a-Service
;; Polls a RedisMQ for messages and feeds them to a Cloud Function

;; Imports
(var Lottie (require "./lottie")
     cloud-function Lottie.lottie
     R (require "rsmq")
     rsmq (new R))

;; Config
(when process.env.DEBUG
  (console.log "DEBUG set, function set to console.log")
  (assign cloud-function (# (context data)
                            (console.log data))))

;; Constants
(var INTERVAL 1000)

;; Set up context object for cloud functions
(var context {
     success: (# (m) (ternary m
                              (console.log "Function successfully returned" m)
                              (console.log "Function succeeded")))
     failure: (# (e) (ternary e
                              (console.log "Function error" e)
                              (console.log "Function returned 'failed'")))})

(def process-message (message)
     (cloud-function context message))

(def poll-queue ()
     (set-timeout
       (#> (rsmq.pop-message
                { qname: 'Q }
                (# (err, res)
                   (ternary err
                            (console.log "MQ error" err)
                            (when (has-key? res 'id)
                              (process-message res)))))
           (poll-queue))
       INTERVAL))

(poll-queue)
