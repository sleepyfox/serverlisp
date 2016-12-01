;; Imports
(var request (get (require 'http) 'request))
 
;; Constants
(var HOST "api.stathat.com"
     STATHAT_SUCCESS 200)

;; Behaviour

;; Takes a booking object and transforms it into a stat object
(def create-stat (message)
     { ezkey: "lol_n00bz"
       data: [
         { stat: "tee-times.bookings" count: 1 }
         { stat: (+ "tee-times.venue." message.venue) count: 1 }
         { stat: "tee-times.pax" count: message.pax }
         { stat: (+ "tee-times.agent."
                    (extract-name-from-email message.salesperson))
           count: message.pax }]})

;; Send a stat object in buffer to Stathat
(def send-stats (buffer, context)
  (var options {
       hostname: HOST
       method: 'POST
       headers: { "Content-Type": "application/json" }
       path: "/ez" })
  (var cb (# (res)
    ; Sometimes StatHat reports errors in the HTTP status code.
    ; Sometimes it reports a 200 but has a non-200 status in the JSON body.
    ; We need to detect both.
             (ternary (!= res.statusCode STATHAT_SUCCESS)
                      (context.failure res.statusCode.toString)
                      (res.on 'data (# (data)
                                       (var body (.toString data))
                                       (ternary (= data.status STATHAT_SUCCESS)
                                                (context.failure body)
                                                (context.success body)))))))
  (pipe (request options cb)
        (.end buffer 'utf8)))

;; Expects a hydrated booking object with an event_type and a payload
(def is-sale? (message)
     (= "sale" message.event_type))

;; Takes a raw RedisMQ message that has a String 'message' payload
;; and parses the string into an object. If it can't parse the JSON
;; it returns an empty object
(def decode-message (message)
     (try (.parse JSON message.message)
          {}))

(def extract-name-from-email (email)
     (ternary (< (.indexOf email "@") 0)
              (or email 'anonymous)
              (.substr email 0 (.indexOf email "@"))))

(def parse-pubsub-message (service)
     (# (context data)
        (var message (decode-message data))
        (if (not (has-key? data 'id))
            (do 
             (console.log "Empty message")
             (.failure context))
            (is-sale? message)
            (do
             (console.log "Sale: " (JSON.stringify message.payload))
             (.success context))
            ;; else
            (do                        
             (ternary (exists? message.payload)
                      (console.log "Not a sale: " (JSON.stringify message.payload))
                      (console.log "Not a sale: no message payload"))
             (.success context)))))

      
(set module 'exports {
  lottie: (parse-pubsub-message send-stats)
  _send-stats: send-stats
  _is-sale?: is-sale?
  _decode-message: decode-message
  _extract-name: extract-name-from-email
  _create-stat: create-stat })
