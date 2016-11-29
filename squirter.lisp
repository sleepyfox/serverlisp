;; Imports
(var AWS (require "aws-sdk"))
(AWS.config.update { region: "us-east-1" })
(var sns (new AWS.SNS))
(var R (require "rsmq"))
(var rsmq (new R))

;; Constants
(var TIME_DELAY (or process.env.DELAY 5000))

;; Send a message to AWS SNS
(def send-sns-message (json)
     (var params {
          Message: (JSON.stringify json)
          MessageStructure: "json"
          Subject: "A message for lottie"
          TopicArn: "arn:aws:sns:us-east-1:859676677036:test-topic" })

     (sns.publish params (# (err, data)
                            (ternary err
                                     (console.log err err.stack)
                                     (console.log "sns:" data)))))

;; Send a message to a local Redis Message Queue
(def send-rsmq-message (m)
     (rsmq.send-message { qname: 'Q message: (JSON.stringify m) }
                        (# (err, response)
                           (ternary err
                                    (console.log "error" err)
                                    (console.log "message" response))
                           (process.exit))))
     
;; Returns a random number from 0 (inclusive) to n (exclusive)
(def random (n)
     (Math.floor (* (Math.random) n)))

;; Returns a random element from the given array
(def sample (array)
     (get array (random array.length)))

;; Chooses a random venue
(def choose-venue ()
     (sample ["The Belfry" "Celtic Manor Resort"]))
     
;; Choose a random salesperson
(def choose-salesperson ()
     (sample ["Fred Bloggs" "Jane Doe" "John Smith" "Mary Major"]))

;; Given a venue return a random course
(def choose-course (venue)
     (if (= venue "The Belfry")
         (sample ["Brabazon" "PGA National" "Derby"])
         (sample ["Roman Road" "Montgomerie" "Twenty Ten"])))

;; Returns a random number between 1 and 4
(def choose-pax ()
     (sample [1 2 3 4]))

;; Creates a new sale object from a random choice of
;; venue, course, pax and salesperson
(def create-new-sale ()
     (var venue (choose-venue))
     { salesperson: (choose-salesperson)
       venue: venue
       course: (choose-course venue)
       pax: (choose-pax)})

;; Sends a message via the message bus
(def send-message (sale)
     (console.log (JSON.stringify sale null 2))
     (.sendMessage eventHubs {
                   message: sale
                   deviceId: 1}))

;; sends a new message every n seconds
(def create-data-loop ()
     (set-timeout (#>
                   (console.log "status" (send-message (create-new-sale)))
                   (create-data-loop)) TIME_DELAY))

;;(create-data-loop)
;;(send-sns-message (create-new-sale))   
(send-rsmq-message (create-new-sale))

