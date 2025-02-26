(local awful (require :awful))
(local gears (require :gears))
(local menubar (require :menubar))
(local {: all-clients} (require :core))

(fn jump-to-tag [tag]
  (awful.tag.viewmore [tag] tag.screen 1)
  (set client.focus (first tag.screen.clients)))

(fn focus-or-launch [app-class window-id]
  (let [cl (-?>> (all-clients)
                 (filter
                  (fn [c]
                    (and
                     (not= c.role "pop-up")
                     ;; (not= c.role )
                     (if window-id
                         (= c.window window-id)
                         (= c.class app-class)))))
                 first)
        app-name (if (= app-class "Brave-browser") "Brave" app-class)]
    ;; if we find the matching client, we switch to it,
    ;; otherwise find the app with the same name, and launch it
    (if cl
        (do
          (set cl.minimized false)
          (let [scr (awful.screen.focused)
                client-tag (first (cl:tags))]
            (when (not= scr.selected_tag client-tag)
              (jump-to-tag client-tag)))
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

(fn move-win-to-other-screen []
  (when client.focus
    (let [c client.focus]
      (c:move_to_screen)
      (gears.timer.weak_start_new
       0.01
       (fn []
         (focus-or-launch c.class)
         false)))))

(fn move-win-to-tag [tag]
  ;; if no client on focus, grab first window on the current screen
  (let [cur-scr (awful.screen.focused)]
    (when (not client.focus)
      (set client.focus (first cur-scr.clients)))

    ;; tag from other screen, let's move the window over there
    (when (not= tag.screen cur-scr)
      (move-win-to-other-screen))
    (when client.focus
      (let [clnt client.focus]
        (client.focus:move_to_tag tag)
        (jump-to-tag tag)
        (set client.focus clnt)))))

{: jump-to-tag
 : move-win-to-other-screen
 : move-win-to-tag
 : focus-or-launch}
