(local awful (require :awful))
(local gears (require :gears))
(local hotkeys_popup (require :awful.hotkeys_popup))
(local menubar (require :menubar))
(local {: modkey
        : superkey
        : all-clients
        : map-key
        } (require :core))
(local { : edit-with-emacs } (require :emacs))

;; Keyboard map indicator and switcher
(local my_keyboard_layout (awful.widget.keyboardlayout))

(fn focus-byidx-global [i c]
  (let [old awful.client.visible]
    (set awful.client.visible (fn [_ s] (old nil s)))
    (awful.client.focus.byidx i c)
    (set awful.client.visible old)))

(fn next-client-of-all [_i]
  (let [all (all-clients)
        prev (-?>> all
                   (take-while
                    (fn [c] (not= client.focus c)))
                   last)
        next (-?>> all (remove (fn [x] (= x prev)))
                   last)
        ]
    ;; (lame_dbg prev.class)
    ;; (lame_dbg next.class)
    (when next
      (next:emit_signal "request::activate"
                        "client.focus.byidx"
                        {:raise true}))))

;; (fn focus_by_idx [idx c]
;;   "focus.byidx version that works for all screens"
;;   (set c.marked true)
;;   (let [clients (-?> (awful.screen.focused)
;;                      (: :get_clients true))
;;         marked-ct (->> clients
;;                        (filter (fn [x] x.marked))
;;                        count)]
;;     ;; (lame_dbg clients)
;;     ;; (lame_db marked-ct)
;;     (when (<= (count clients) marked-ct)
;;       (awful.screen.focus_relative -1)
;;       (awful.client.getmarked))
;;     (awful.client.focus.byidx idx)
;;     (when client.focus
;;       (client.focus:raise)
;;       ;; (set client.focus.marked true)
;;       )))

(local window_switcher (require :lib.window_switcher))
(window_switcher.enable
 {:type :thumbnail ; set to anything other than "thumbnail" to disable client previews
  :hide_window_switcher_key :Escape
  :minimize_key :n
  :unminimize_key :N
  :kill_client_key :q
  :cycle_key "."
  :previous_key :Left
  :next_key :Right
  :vim_previous_key :k
  :vim_next_key :j
  :cycleClientsByIdx next-client-of-all
  :filterClients all-clients})

(local
 global_keys
 (gears.table.join
  (map-key superkey :s hotkeys_popup.show_help "this help" :awesome)
  (map-key superkey :6 awesome.restart "reload awesome" :awesome)
  ;; (map-key [modkey] "." (fn [] (awesome.emit_signal "bling::window_switcher::turn_on"))
  ;;          "window switcher" :group :client)

  (map-key [modkey :Control] "."
           (fn [c] (focus-byidx-global 1 c))
           "focus next by index" :client)

  (map-key [modkey :Control] ","
           (fn [c] (focus-byidx-global -1 c))
           "focus prev by index" :client)

  ;; (awful.key [modkey] "." (fn [c]
  ;;                           (awful.client.focus.byidx 1)
  ;;                           (when c.focus
  ;;                             (awful.client.setmaster c.focus)))
  ;;            {:description "next to master" :group :client})
  ;; (awful.key [modkey] "," (fn [c]
  ;;                           (awful.client.focus.history.previous)
  ;;                           (when c.focus
  ;;                             (awful.client.setmaster c.focus)))
  ;;            {:description "prev to master" :group :client})
  (map-key superkey :1
           (fn []
             (awful.client.run_or_raise
              :brave
              (fn [c] (awful.rules.match c {:class :Brave-browser}))))
           "jump to Brave" :launcher)

  (map-key superkey :2
           (fn []
             (awful.client.run_or_raise
              :emacs
              (fn [c] (awful.rules.match c {:class :Emacs}))))
           "jump to Emacs" :launcher)

  (map-key superkey :3
           (fn []
             (awful.client.run_or_raise
              :kitty
              (fn [c] (awful.rules.match c {:class :kitty}))))
           "jump to Kitty"  :launcher)

  (map-key [modkey :Control] "]" (fn [] (awful.tag.incmwfact 0.01))
           "widen horizontally" :layout)
  (map-key [modkey :Control] "[" (fn [] (awful.tag.incmwfact -0.01))
           "shrink horizontally" :layout)
  (map-key superkey :r (fn []
                         (-?> (awful.screen.focused)
                              (. :my_promptbox)
                              (: :run)))
           "run prompt" :launcher)
  (map-key superkey :l (fn []
                         (menubar.refresh)
                         (menubar.show))
           "show the menubar" :launcher)))

(local
 client_keys
 (gears.table.join
  ;; (awful.key [modkey :Control] "."
  ;;            (fn [c] (focus_by_idx 1 c))
  ;;            {:description "focus next by index" :group :client})
  ;; (awful.key [modkey :Control] ","
  ;;            (fn [c] (focus_by_idx -1 c))
  ;;            {:description "focus prev by index" :group :client})
  (map-key [modkey :Control] :Return
             (fn [c]
               (c:swap (awful.client.getmaster)))
             "move to master" :client)
  (map-key superkey :o (fn [c] (c:move_to_screen))
           "move to screen" :client)
  (map-key superkey :f
           (fn [c]
             (set c.fullscreen (not c.fullscreen))
             (c:raise))
           "fullscreen" :client)
  (map-key superkey :m
           (fn [c]
             (set c.maximized (not c.maximized))
             (c:raise))
           "maximize" :client)
  (map-key superkey "\\"
           (fn [c]
             (set c.maximized_vertical
                  (not c.maximized_vertical))
             (c:raise))
           "maximize vertically" :client)
  (map-key superkey "-"
           (fn [c]
             (set c.maximized_horizontal
                  (not c.maximized_horizontal))
             (c:raise))
           "maximize horizontally" :client)
  (map-key [modkey :Control] "o" edit-with-emacs
           "edit with Emacs" :client)))

(root.keys global_keys)

;; Mouse bindings
(local {: my_main_menu } (require :menu))
(root.buttons
 (gears.table.join
  (awful.button [] 3
                (fn [] (my_main_menu:toggle)))
  (awful.button [] 4 awful.tag.viewnext)
  (awful.button [] 5 awful.tag.viewprev)))

(local
 client_buttons
 (gears.table.join
  (awful.button
   nil 1
   (fn [c]
     (c:emit_signal "request::activate"
                    :mouse_click
                    {:raise true})))
  (awful.button
   [modkey] 1
   (fn [c]
     (c:emit_signal "request::activate"
                    :mouse_click
                    {:raise true})
     (awful.mouse.client.move c)))
  (awful.button
   [modkey] 3
   (fn [c]
     (c:emit_signal "request::activate"
                    :mouse_click
                    {:raise true})
     (awful.mouse.client.resize c)))))

{: modkey
 : superkey
 : client_keys
 : global_keys
 : my_keyboard_layout
 : client_buttons}
