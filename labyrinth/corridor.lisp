(in-package :crawler2)


(defmethod filter-carvable ((stage labyrinth) neighborhood)
  (nmap-early-exit-reduction neighborhood #'carvedp))

(defmethod pick-cell ((stage labyrinth) cells)
  (if (> (rng 'inc) (corridor-windiness stage))
      (rng 'elt :list cells)
      (first cells)))

(defmethod choose-uncarved ((stage labyrinth) neighborhood)
  (let ((results))
    (dolist (dir '(n s e w))
      (let ((c1 (funcall dir neighborhood)))
        (when (and (> (cell-x c1) 0)
                   (> (cell-y c1) 0)
                   (< (cell-x c1) (1- (width stage)))
                   (< (cell-y c1) (1- (height stage))))
          (let ((c2 (funcall dir neighborhood 2)))
            (unless (carvedp c2)
              (push (list c1 c2) results))))))
    (rng 'elt :list results)))

(defmethod carve-direction ((stage labyrinth) origin cells)
  (with-slots (x y) origin
    (let ((neighborhood (nh-realize (layout :ortho :maximum 2) stage x y)))
      (if-let ((choice (choose-uncarved stage neighborhood)))
        (loop :for cell :in choice
              :do (carve stage cell :feature :corridor)
              :finally (push cell cells))
        (deletef cells origin)))
    cells))

(defmethod carve-corridor ((stage labyrinth) neighborhood)
  (let ((origin (origin neighborhood)))
    (carve stage origin :region (make-region stage) :feature :corridor)
    (loop :with cells = (list origin)
          :while cells
          :for cell = (pick-cell stage cells)
          :do (setf cells (carve-direction stage cell cells)))))

(defmethod filter-dead-end ((stage labyrinth) neighborhood)
  (let ((dirs (remove-if #'identity (nmap neighborhood #'carvedp))))
    (and (carvedp (origin neighborhood))
         (>= (length dirs) 3))))

(defmethod erode-dead-end ((stage labyrinth) neighborhood)
  (flet ((bail-carved (x)
           (when (carvedp x)
             (return-from erode-dead-end (cell-nh stage x (layout :ortho))))))
    (uncarve stage (origin neighborhood))
    (nfilter neighborhood #'bail-carved)))
