;; Imports
(var request (get (require 'http) 'request))
 
;; Constants
(var HOST "api.stathat.com"
     STATHAT_SUCCESS 200)

;; Behaviour
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


(def parse-pubsub-message (service)
     (#> ))
      
(set module 'exports {
  lottie: (parse-pubsub-message send-stats)
  send_stats: send-stats })
  ;; parse_pubsub_message: parse_pubsub_message
  ;; _create_stat: create_stat
  ;; _extract_name: extract_name_from_email
  ;; _is_booking: is_booking
  ;; _total_pax: total_pax

