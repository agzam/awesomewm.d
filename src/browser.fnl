(local awful (require :awful))
(local gears (require :gears))
(local {: merge} (require :functional))

(local {: modkey} (require :core))

;; (local
;;  browser-keys
;;  (awful.key
;;   [:Control] "n"
;;   (fn []

;;     )
;;   {:description "window switcher"
;;    :group :client})

;;  )
;;

(client.connect_signal
 :focus
 (fn [c]
   (when (= c.class :Brave-browser)
     (let [keys (merge (c.keys c)
                       (awful.key [:Control] :n
                                  (fn [c]
                                    (lame_dbg "dude, it worked"))))]
       (c.keys c keys)))))
