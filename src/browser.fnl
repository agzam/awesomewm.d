(local awful (require :awful))
(local gears (require :gears))
(local {: merge : seq?} (require :fun))
(local {: simulate_key} (require :keybindings))
(local {: modkey} (require :core))

(local
 browser_keys
 (gears.table.join
  {:app_local_class :Brave-browser}
  (simulate_key [:Control] :n [] :Down)
  (simulate_key [:Control] :p [] :Up)
  (simulate_key [:Mod4] :l [:Control] :l)))

{ : browser_keys }
