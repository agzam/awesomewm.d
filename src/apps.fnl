(local awful (require :awful))
(local gears (require :gears))
(local menubar (require :menubar))
(local {: all-clients} (require :core))

(fn focus-or-launch [app-class window-id]
  (let [cl (-?>> (all-clients)
                 (filter
                  (fn [c]
                    (if window-id
                        (= c.window window-id)
                        (= c.class app-class))))
                 first)
        app-name (if (= app-class "Brave-browser") "Brave" app-class)]
    ;; if we find the matching client, we switch to it,
    ;; otherwise find the app with the same name, and launch it
    (if cl
        (do
          (set cl.minimized false)
          (awful.client.focus.byidx 0 cl))
        (do
          (menubar.refresh)
          (gears.timer.weak_start_new
           0.1
           (fn []
             (let [cmd (. (-?>>
                           menubar.menu_entries
                           (filter (fn [x] (= x.name app-name)))
                           first)
                        :cmdline)]
               (awful.spawn.with_shell cmd)
               false)))))))

{ : focus-or-launch }
