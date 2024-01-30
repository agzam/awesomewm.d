(import-macros {: unless } :macros)

(fn compose [...]
  (let [fs [...]
        total (length fs)]
    (fn [v]
      (var res v)
      (for [i 0 (- total 1)]
        (let [f (. fs (- total i))]
          (set res (f res))))
      res)))

(fn seq?
  [tbl]
  (~= (. tbl 1) nil))

(fn seq [tbl]
  (if (seq? tbl)
      (ipairs tbl)
      (pairs tbl)))

(fn empty?
  [coll]
  (match (type coll)
    :string (= coll "")
    :table (not (seq? coll))))

(fn apply [f ...]
  (let [args [...]]
    (f (table.unpack args))))

(fn complement [f]
  (fn [...]
    (not (f ...))))

(fn inc [x] (+ x 1))
(fn dec [x] (- x 1))

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

(fn drop [n tbl]
  (icollect [i v (ipairs tbl)]
    (when (< n i) v)))

(fn drop-while [pred coll]
  (let [res []]
    (each [_ v (pairs coll)]
      (when (not (pred v))
        (table.insert res v)))
    res))

(fn take-while [pred coll]
  (let [res []]
    (each [_ v (pairs coll) &until (not (pred v))]
      (table.insert res v))
    res))

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

(fn reduce [f acc seq]
  (accumulate [acc acc _ v (ipairs seq)]
    (f acc v)))

(fn get-in [paths tbl]
  (reduce (fn [tbl path]
            (-?> tbl (. path))) tbl paths))

(fn concat [...]
  (reduce (fn [cat tbl]
            (each [_ v (ipairs tbl)]
              (table.insert cat v))
            cat) [] [...]))

(fn zip [...]
  "Groups corresponding elements from multiple lists into a new list, truncating at the length of the smallest list."
  (let [tbls [...]
        result []]
    (if (= 1 (length tbls))
        (table.insert result (. tbls 1))
        (let []
          (for [idx 1 (length (. tbls 1))]
            (let [inner []]
              (each [_ tbl (ipairs tbls) &until (not (. tbl idx))]
                (table.insert inner (. tbl idx)))
              (table.insert result inner)))))
    result))

(fn map [f ...]
  (let [args [...]
        tbls (zip (table.unpack args))]
    (if (= 1 (count args))
        (icollect [_ v (pairs (first args))]
          (apply f v))
        (accumulate [acc []
                     _ t (ipairs tbls)]
          (concat acc [(apply f (table.unpack t))])))))

(fn flatten [item result]
  (let [result (or result {})]
    (if (= (type item) :table)
        (each [_ v (pairs item)] (flatten v result))
        (tset result (+ (length result) 1) item))
    result))

(fn merge [...]
  (let [tbls [...]]
    (reduce (fn _merger [merged tbl]
              (each [k v (pairs tbl)]
                (tset merged k v))
              merged) {} tbls)))

(fn filter [f tbl]
  (reduce (fn [xs v k]
            (when (f v k)
              (table.insert xs v))
            xs) [] tbl))

(fn remove [pred coll]
  (filter (complement pred) coll))

(fn mapcat [f ...]
  (let [cols [...]]
    (apply concat (table.unpack (apply map f (table.unpack cols))))))

(fn some [f tbl]
  (let [filtered (filter f tbl)]
    (<= 1 (length filtered))))

(fn conj [tbl e]
  "Return a new list with the element e added at the end"
  (concat tbl [e]))

{
 : apply
 : complement
 : compose
 : concat
 : conj
 : count
 : dec
 : drop
 : drop-while
 : empty?
 : filter
 : first
 : flatten
 : get
 : get-in
 : has-some?
 : identity
 : inc
 : join
 : last
 : map
 : mapcat
 : merge
 : noop
 : range
 : reduce
 : remove
 : seq
 : seq?
 : some
 : take-while
 }
