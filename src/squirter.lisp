;; Imports
(var R (require "rsmq")
     rsmq (new R))

;; Constants
(var TIME_DELAY (or process.env.DELAY 5000))
(var NOISE 0.7)

;; Create a queue if it doesn't exist on the redis server
(def create-queue ()
     (rsmq.create-queue { qname: 'Q }
                        (# (err,res)
                           (ternary (= 1 res)
                                    (console.log "Queue created")
                                    (console.log "Queue exists")))))

;; Send a message to a local Redis Message Queue
(def send-rsmq-message (m)
     (rsmq.send-message { qname: 'Q message: (JSON.stringify m) }
                        (# (err, response)
                           (ternary err
                                    (console.log "error" err)
                                    (console.log "message" response)))))
     
;; Returns a random number from 0 (inclusive) to n (exclusive)
(def random (n)
     (Math.floor (* (Math.random) n)))

;; Returns a random element from the given array
(def sample (array)
     (get array (random array.length)))

;; Chooses a random venue
(def choose-venue ()
     (sample ["the-belfry" "celtic-manor-resort"]))
     
;; Choose a random salesperson
(def choose-salesperson ()
     (sample ["fred.bloggs@mygolftravel.com"
              "jane.doe@mygolftravel.com"
              "john.smith@mygolftravel.com"
              "mary.major@mygolftravel.com"]))

;; Given a venue return a random course
(def choose-course (venue)
     (ternary (= venue "the-belfry")
              (sample ["brabazon" "pga-national" "derby"])
              (sample ["roman-road" "montgomerie" "twenty-ten"])))

;; Returns a random number between 1 and 4
(def choose-pax ()
     (sample [1 2 3 4]))

;; Creates a new sale object from a random choice of
;; venue, course, pax and salesperson
(def create-new-sale ()
     (var venue (choose-venue))
     { event_type: "sale"
       timestamp: (.toISOString (new Date))
       system: "Online tee-sheet"
       payload: {
         salesperson: (choose-salesperson)
         venue: venue
         course: (choose-course venue)
         pax: (choose-pax)}})

;; Returns true if random is > NOISE
(def signal-to-noise ()
     (> NOISE (Math.random)))

;; sends a new message every n seconds
(def create-data-loop ()
     (set-timeout (#>
                   (send-rsmq-message
                     (ternary (signal-to-noise)
                              (create-new-sale)
                              { event_type: "other stuff"
                                payload: { random: "kittens" }}))
                   (create-data-loop)) TIME_DELAY))

(console.log "Event every" (/ TIME_DELAY 1000 ) "secs")
(create-queue)
(create-data-loop)
