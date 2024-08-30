(local awful (require :awful))
(local gears (require :gears))
(local {: simulate-key } (require :core))
(local core (require :core))
(local {: modkey } core)


(local
 browser-local-keys
 (gears.table.join
  {:app_local_class :Brave-browser}
  (simulate-key [:Control] :n [] :Down)
  (simulate-key [:Control] :p [] :Up)
  (simulate-key [modkey] :l [:Control] :l)
  (simulate-key [modkey] :j [:Control :Shift] :Tab)
  (simulate-key [modkey] :k [:Control] :Tab)
  (simulate-key [:Control] :j [] :Down)
  ;; (simulate-key [:Control] :k [] :Up)
  (simulate-key [modkey] :t [:Control] :t)
  (simulate-key [modkey] :w [:Control] :w)
  (simulate-key [:Mod1] :BackSpace [:Control] :BackSpace)
  (->> (range 1 9)
       (map #(let [k (tostring $1)] (simulate-key [modkey] k [:Control] k)))
       (flatten))))

(fn get-brave-client []
  (->> (core.all-clients)
       (filter (fn [x] (and
                        (= x.class "Brave-browser")
                        (starts-with? x.name "New Private Tab"))))
       first))

(fn open-private-in-new-tab []
  (awful.tag.viewnext)
  (awful.spawn.easy_async
   "brave --incognito"
   (gears.timer.weak_start_new
    0.1
    #(let [bb (get-brave-client)]
       (when bb (bb:move_to_screen screen.primary)))
    false))
  (gears.timer.weak_start_new
   0.2
   #(let [bb (get-brave-client)]
      (set client.focus bb))
   false))

{ : browser-local-keys
  : open-private-in-new-tab
  }
