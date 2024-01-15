(local modkey :Mod4)
(local superkey [modkey :Control :Mod1 :Shift])

(fn all-screens []
  (icollect [_ s (ipairs _G.screen)] s))

(fn all-clients []
  (let [stacked true]
    (-?>> (all-screens)
          (mapcat (fn [scr] (when scr (scr:get_all_clients stacked)))))))

{
 : all-screens
 : all-clients
 : modkey
 : superkey
 }
