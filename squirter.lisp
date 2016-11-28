;; Imports
(var AWS (require "aws-sdk"))
(var sns (new AWS.SNS {
              region: "us-east-1" }))

;; Constants
(var TIME_DELAY (or process.env.DELAY 5000))

(def construct-message ()
     (var params {
          TopicArn: "arn:aws:sns:us-east-1:859676677036:test-topic"
          Subject: "I am a subject line"
          Message: (JSON.stringify { message: "I am a JSON message" })
          MessageAttributes: {
          attr: {
            DataType: "String"
            StringValue: "This is a message attribute" }}}))

;; (sns.publish (construct-message) (# (err, data)
;;                        (ternary err
;;                                 (console.log err err.stack)
;;                                 (console.log data))))

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
(def send-message (a)
     (console.log (JSON.stringify a null 2)))

;; sends a new message every n seconds
(def create-data-loop ()
     (set-timeout (#>
                   (send-message (create-new-sale))
                   (create-data-loop)) TIME_DELAY))

(create-data-loop)
     
