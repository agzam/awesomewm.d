;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Simple Utils
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(fn compose [...]
  (let [fs [...]
        total (length fs)]
    (fn [v]
      (var res v)
      (for [i 0 (- total 1)]
        (let [f (. fs (- total i))]
          (set res (f res))))
      res)))

(fn get [prop-name tbl]
  (if tbl
      (. prop-name tbl)
      (fn [tbl]
        (. tbl prop-name))))

(fn has-some? [list]
  (and list (< 0 (length list))))

(fn identity [x]
  x)

(fn join [sep list]
  (table.concat list sep))

(fn first [list]
  (. list 1))

(fn last [list]
  (. list (length list)))

(fn noop [] nil)

(fn range [start end]
  (let [t []]
    (for [i start end]
      (table.insert t i))
    t))

(fn count [tbl]
  "Returns number of elements in a table"
  (var cnt 0)
  (each [_ _ (pairs tbl)]
    (set cnt (+ cnt 1)))
  cnt)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Reduce Primitives
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(fn seq?
  [tbl]
  (~= (. tbl 1) nil))

(fn seq [tbl]
  (if (seq? tbl)
      (ipairs tbl)
      (pairs tbl)))

(fn reduce [f acc tbl]
  (var result acc)
  (each [k v (seq tbl)]
    (set result (f result v k)))
  result)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Reducers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(fn get-in [paths tbl]
  (reduce (fn [tbl path]
            (-?> tbl (. path))) tbl paths))

(fn map [f tbl]
  (reduce (fn [new-tbl v k]
            (table.insert new-tbl (f v k))
            new-tbl) [] tbl))

(fn merge [...]
  (let [tbls [...]]
    (reduce (fn merger [merged tbl]
              (each [k v (pairs tbl)]
                (tset merged k v))
              merged) {} tbls)))

(fn filter [f tbl]
  (reduce (fn [xs v k]
            (when (f v k)
              (table.insert xs v))
            xs) [] tbl))

(fn concat [...]
  (reduce (fn [cat tbl]
            (each [_ v (ipairs tbl)]
              (table.insert cat v))
            cat) [] [...]))

(fn some [f tbl]
  (let [filtered (filter f tbl)]
    (<= 1 (length filtered))))

(fn conj [tbl e]
  "Return a new list with the element e added at the end"
  (concat tbl [e]))

(fn butlast [tbl]
  "Return a new list with all but the last item"
  (slice 1 -1 tbl))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Exports
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

{: butlast
 : compose
 : concat
 : conj
 : filter
 : first
 : get
 : get-in
 : has-some?
 : identity
 : join
 : last
 : map
 : merge
 : noop
 : reduce
 : count
 : seq
 : seq?
 : some
 : slice}
