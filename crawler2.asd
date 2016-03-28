(defsystem #:crawler2
  :name "Crawler"
  :author "Michael Fiano <michael.fiano@gmail.com>"
  :version "0.1"
  :license "MIT"
  :description "A procedural dungeon generation library."
  :depends-on (#:alexandria
               #:cl-variates
               #:cl-speedy-queue)
  :serial t
  :components
  ((:file "package")
   (:file "util")
   (:file "random")
   (:file "neighborhood")
   (:file "stage-basic")
   (:file "stage-buffered")
   (:file "cell")
   (:module "labyrinth"
    :components
    ((:file "stage")
     (:file "cell")
     (:file "region")
     (:file "connector")
     (:file "room")
     (:file "corridor")
     (:file "stairs")))))
