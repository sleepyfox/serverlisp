;; Imports
(var mocha (require "mocha")
     assert (require "assert")
     Lottie (require "./lottie"))

;; (describe "a suite"
;;             (#> (it "should do math"
;;                       (#> 1))))

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
                     ezkey: "sleepyfox@gmail.com"
                     data: [{ stat: 'tee-times.test', count: 1 }]})
              (Lottie.send_stats (JSON.stringify stat) context)))))
