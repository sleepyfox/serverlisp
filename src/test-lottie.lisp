;; Imports
(var mocha (require "mocha")
     assert (require "assert")
     Lottie (require "./lottie"))

(describe "A stats sender"
   (#> (it "can send data to stathat successfully"
           (# (done)
              (var context {
                   success: (# (m)
                               (var msg (JSON.parse m))
                               (assert.equal msg.status 200)
                               (done))
                   failure: (# (m)
                               (done (new Error (+ "stathat request failed: " m))))
                   }
                   stat {
                     ezkey: "lol_n00bz"
                     data: [{ stat: 'tee-times.test', count: 1 }]})
              (Lottie._send-stats (JSON.stringify stat) context)))))

(var non-sale-event {
     "id":"ektrwqckg5VVEoO6h3FEbxZgQbAhRocM"
     "message": "{\"event_type\":\"other stuff\",\"payload\":{\"random\":\"kittens\"}}"
     "rc":1
     "fr":1480595120597
     "sent":1480594904562 }
     sale-event {
     "id":"ektrwtbvfpmVLBeKgK3mjh7ob0YTCogk"
     "message":"{\"event_type\":\"sale\",\"payload\":{\"salesperson\":\"john.smith@mygolftravel.com\",\"venue\":\"the-belfry\",\"course\":\"brabazon\",\"pax\":2}}"
     "rc":1
     "fr":1480595122273
     "sent":1480594909569 })

(describe "A message filter"
  (#> (it "returns false if the event type isn't a sale"
          (#> (var event (JSON.parse non-sale-event.message))
              (assert.equal false (Lottie._is-sale? event))))
      (it "returns true if the event type is a sale"
          (#> (var event (JSON.parse sale-event.message))
              (assert.equal true (Lottie._is-sale? event))))))

(describe "a stathat stat creator"
   (#> (it "should be able to create a new stat package"
           (#> (var event (JSON.parse sale-event.message))
               (var stat (Lottie._create-stat event.payload))
               (assert.ok stat)
               (assert.deep-equal stat
                 { ezkey: "lol_n00bz"
                   data: [
                     { stat: "tee-times.bookings" count: 1 }
                     { stat: "tee-times.venue.the-belfry", count: 1 }
                     { stat: "tee-times.pax", count: 2 }
                     { stat: "tee-times.agent.john.smith", count: 2 }
                     ]})))))

(describe "A name extractor"
   (#> (it "should be able to extract a name from an email"
           (#> (assert.equal 'sleepyfox
                             (Lottie._extract-name "sleepyfox@gmail.com"))))
       (it "should say anonymous if email blank"
           (#> (assert.equal 'anonymous
                             (Lottie._extract-name ""))))
       (it "should say a name if there is no @ present"
           (#> (assert.equal 'fox
                             (Lottie._extract-name "fox"))))))

(describe "A message decoder"
   (#> (it "should be able to decode a valid sales object"
           (#> (assert.deep-equal (Lottie._decode-message sale-event)
                  { event_type: "sale"
                    payload: {
                      salesperson: "john.smith@mygolftravel.com"
                      venue: "the-belfry"
                      course: "brabazon"
                      pax: 2 }})))
       (it "should be able to decode a non-sales event"
           (#> (assert.ok (Lottie._decode-message non-sale-event))))
       (it "should return an empty object on a non-object payload"
           (#> (assert.deep-equal
                 {}
                 (Lottie._decode-message {id: 1 message: "Oops!" }))))))
