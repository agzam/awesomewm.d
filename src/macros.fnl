;; if-let and when-let implementations were borrowed from
;; https://github.com/rktjmp/pact.nvim/blob/master/fnl/pact/lib/ruin/let/init-macros.fnl#L21

(fn if-let-impl [bindings if-expr ?else-expr compare]
  (fn copy [t]
    (let [out []]
      (each [_ v (ipairs t)] (table.insert out v))
      (setmetatable out (getmetatable t))))
  ;; TODO faccumulate
  (var acc `(values true ,if-expr))
  (for [i (length bindings) 1 -2]
    (let [bind-sym (gensym (tostring (. bindings (- 1 1))))
          patched-comp (let [cloned (copy compare)]
                         (doto cloned
                           (table.insert bind-sym)))]
      (set acc `(let [,bind-sym ,(. bindings i)]
                  (if ,patched-comp
                      (let [,(. bindings (- i 1)) ,bind-sym]
                        ,acc)
                      (values false))))))
  `(let [(all# val#) ,acc]
     (if all# val# ,?else-expr)))

(fn if-let [bindings if-expr ?else-expr]
  "Check `bindings` in order, if all are truthy, evaluate `if-expr`, otherwise `?else-expr` or nil.

  ```
  (if-let [a 10
           b 20]
    (+ a b)
    (print :otherwise))
  ```"
  ;; (assert-compile (sequence? bindings) "must be a sequence" bindings)
  (assert-compile (= 0 (% (length bindings) 2)) "must provide even number of bindings" bindings)
  (assert-compile if-expr "requires a body expression and optional else expression")
  (if-let-impl bindings if-expr ?else-expr `(and)))

(fn when-let [bindings ...]
  "Check `bindings` in order, if all are truthy, evaluate `...` or nil.

  ```
  (when-let [a 10
             b 20]
    (+ a b)
    (* a b)))
  ```"
  ;; (assert-compile (sequence? bindings) "must be a sequence" bindings)
  (assert-compile (= 0 (% (length bindings) 2)) "must provide even number of bindings" bindings)
  (assert-compile (<= 1 (select :# ...)) "must provide at least one body expression")
  `(if-let ,bindings (do ,...)))

(fn unless [cond ...]
  `(when (not ,cond) ,...))

{
 : if-let
 : when-let
 : unless
 }
