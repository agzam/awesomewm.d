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
  (simulate-key [:Control] :k [] :Up)))

{ : browser-local-keys }
