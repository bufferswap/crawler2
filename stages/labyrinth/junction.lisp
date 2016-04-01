(in-package :crawler2)

(defmethod create-junctions ((stage labyrinth))
  (loop :with region-id = (current-region stage)
        :for connectors = (connectors (get-region stage region-id))
        :while connectors
        :for source = (rng 'elt :list connectors)
        :for target = (first (remove region-id (adjacent-regions source)))
        :do (make-junction stage source)
            (remove-extra-connectors stage region-id target)
            (move-connectors stage target region-id))
  (convolve stage (layout :orthogonal) #'filter-connectable #'make-extra-junctions))

(defmethod adjacent-junction-p ((stage labyrinth) cell)
  (let ((neighborhood (cell-nh stage cell (layout :orthogonal))))
    (nmap-early-exit-reduction
     neighborhood
     (lambda (x) (featuresp x :junction))
     :reduction any
     :early-exit-continuation t)))

(defmethod make-junction ((stage labyrinth) cell)
  (unless (adjacent-junction-p stage cell)
    (carve stage cell :region-id nil :feature :junction)))

(defmethod make-extra-junctions ((stage labyrinth) neighborhood)
  (when (< (rng 'inc) (junction-rate stage))
    (make-junction stage (origin neighborhood))))

(defmethod filter-connectable ((stage labyrinth) neighborhood)
  (with-accessors ((o origin) (n n) (s s) (e e) (w w)) neighborhood
    (and (not (region-id o))
         (let ((ns (mapcar #'region-id (list n s)))
               (ew (mapcar #'region-id (list e w))))
           (or (and (not (apply #'eql ns))
                    (not (some #'null ns)))
               (and (not (apply #'eql ew))
                    (not (some #'null ew))))))))

(defmethod connect ((stage labyrinth) neighborhood)
  (let ((cell (origin neighborhood)))
    (with-slots (adjacent-regions) cell
      (setf adjacent-regions (remove nil (nmap neighborhood #'region-id)))
      (dolist (region-id adjacent-regions)
        (push cell (connectors (get-region stage region-id)))))))

(defmethod remove-extra-connectors ((stage labyrinth) source target)
  (loop :with region1 = (get-region stage source)
        :with region2 = (get-region stage target)
        :for cell :in (connectors region1)
        :for adjacent = (adjacent-regions cell)
        :when (and adjacent
                   (member source adjacent)
                   (member target adjacent))
          :do (deletef (connectors region1) cell :count 1)
              (deletef (connectors region2) cell :count 1)))

(defmethod move-connectors ((stage labyrinth) source target)
  (let ((region1 (get-region stage source))
        (region2 (get-region stage target)))
    (dolist (cell (connectors region1))
      (setf (adjacent-regions cell)
            (substitute target source (adjacent-regions cell)))
      (push cell (connectors region2)))))

(defmethod connect-regions (stage)
  (convolve stage (layout :orthogonal) #'filter-connectable #'connect))