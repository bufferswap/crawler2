(in-package :crawler2)

(defclass labyrinth-cell (cell)
  ((adjacent-regions :accessor adjacent-regions
                     :initform nil)
   (distance :accessor distance
             :initform -1)))

(defmethod make-cell ((stage labyrinth) x y &key)
  (make-instance 'labyrinth-cell :x x :y y))
