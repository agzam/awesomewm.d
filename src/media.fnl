(local awful (require :awful))
(local gears (require :gears))
(local menubar (require :menubar))
(local { : focus-or-launch } (require :apps))
(local {: all-clients} (require :core))

(fn ytm-player-app-id [cb]
  (menubar.refresh)
  (gears.timer.weak_start_new
   0.1
   (fn []
     (let [cl (-?> (-?>>
                    menubar.menu_entries
                    (filter (fn [x] (= x.name "YouTube Music")))
                    first)
                   (. :cmdline)
                   (: :match "--app%-id=(%w+)"))]
       (cb cl) false))))

(fn activate-ytm-player []
  (ytm-player-app-id
   (fn [_app-id]
     (let [fnd (-?>> (all-clients)
                     (filter
                      (fn [c]
                        (string.match c.name ".* YouTube Music$")))
                     first)]
       (if fnd
           (do
             (set fnd.minimized false)
             (awful.client.focus.byidx 0 fnd))
           (focus-or-launch "YouTube Music"))))))

(fn ytm-press-key [key stay]
  (let [current client.focus]
    (activate-ytm-player)
    (gears.timer.weak_start_new
     0.1
     (fn []
       (awful.spawn.easy_async
        (..
         "xdotool key --clearmodifiers Escape key Escape key i sleep 0.1 key " key)
        (fn []
          (when (not stay)
           (focus-or-launch nil current.window))))
       false))))

(var rules
     [{:rule {:class :mpv}
       :properties {:ontop true
                    :floating false}}])

{ : activate-ytm-player
  : ytm-press-key
  : rules}
