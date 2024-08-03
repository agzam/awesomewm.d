(local awful (require :awful))
(local gears (require :gears))
(local {: simulate-key } (require :core))
(local {: modkey} (require :core))

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

(fn open-private-in-new-tab []
  (awful.tag.viewnext)
  (awful.spawn "brave --incognito"))

{ : browser-local-keys
  : open-private-in-new-tab
  }
