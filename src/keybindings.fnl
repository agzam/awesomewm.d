(local awful (require :awful))
(local gears (require :gears))
(local hotkeys_popup (require :awful.hotkeys_popup))
(local menubar (require :menubar))
(local {: modkey : superkey : all-clients} (require :core))


;; Keyboard map indicator and switcher
(local my_keyboard_layout (awful.widget.keyboardlayout))

(fn simulate_key
  [src-mods src-key dest-mods dest-key]
  "Registers a key that listens for source key (with modifiers) and emits target keypress."
  (awful.key
   src-mods src-key
   (fn []
     (_G.root.fake_input :key_release src-key)
     (when (seq? src-mods)
       (each [_ mkey (ipairs src-mods)]
         (_G.root.fake_input :key_release mkey)))
     (awful.key.execute dest-mods dest-key))))

(fn focus-byidx-global [i c]
  (let [old awful.client.visible]
    (set awful.client.visible (fn [_ s] (old nil s)))
    (awful.client.focus.byidx i c)
    (set awful.client.visible old)))

(fn next-client-of-all [_i]
  (let [all (all-clients)
        prev (-?>> all
                   (take-while
                    (fn [c] (not= _G.client.focus c)))
                   last)
        next (-?>> all (remove (fn [x] (= x prev)))
                   last)
        ]
    (lame_dbg prev.class)
    (lame_dbg next.class)
    (when next
      (next:emit_signal "request::activate"
                        "client.focus.byidx"
                        {:raise true}))))

(fn focus_by_idx [idx c]
  "focus.byidx version that works for all screens"
  (set c.marked true)
  (let [clients (-?> (awful.screen.focused)
                     (: :get_clients true))
        marked-ct (->> clients
                       (filter (fn [x] x.marked))
                       count)]
    (lame_dbg clients)
    (lame_db marked-ct)
    (when (<= (count clients) marked-ct)
      (awful.screen.focus_relative -1)
      (awful.client.getmarked))
    (awful.client.focus.byidx idx)
    (when _G.client.focus
      (_G.client.focus:raise)
      ;; (set _G.client.focus.marked true)
      )))

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
  (awful.key superkey :s hotkeys_popup.show_help
             {:description "this help" :group :awesome})
  (awful.key superkey :6 _G.awesome.restart
             {:description "reload awesome"
              :group :awesome})
  (awful.key [modkey] "."
             (fn [] (_G.awesome.emit_signal "bling::window_switcher::turn_on"))
             {:description "window switcher" :group :client})

  (awful.key [modkey :Control] "." (fn [c] (focus-byidx-global 1 c))
             {:description "focus next by index" :group :client})
  (awful.key [modkey :Control] "," (fn [c] (focus-byidx-global -1 c))
             {:description "focus prev by index" :group :client})

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
  (awful.key superkey :1 (fn []
                           (awful.client.run_or_raise
                            :brave
                            (fn [c]
                              (awful.rules.match c
                                                 {:class :Brave-browser}))))
             {:description "jump to Brave" :group :launcher})
  (awful.key superkey :2 (fn []
                           (awful.client.run_or_raise
                            :emacs
                            (fn [c]
                              (awful.rules.match c
                                                 {:class :Emacs}))))
             {:description "jump to Emacs" :group :launcher})
  (awful.key superkey :3 (fn []
                           (awful.client.run_or_raise
                            :kitty
                            (fn [c]
                              (awful.rules.match c
                                                 {:class :kitty}))))
             {:description "jump to Kitty" :group :launcher})
  (awful.key [modkey :Control] "]" (fn [] (awful.tag.incmwfact 0.01))
             {:description "increase master width factor" :group :layout})
  (awful.key [modkey :Control] "[" (fn [] (awful.tag.incmwfact -0.01))
             {:description "decrease master width factor" :group :layout})
  (awful.key superkey :r (fn []
                           (-?> (awful.screen.focused)
                                (. :my_promptbox)
                                (: :run)))
             {:description "Run prompt" :group :launcher})
  (awful.key superkey :l (fn [] (menubar.show))
             {:description "Show the menubar" :group :launcher})))

(local
 client_keys
 (gears.table.join
  ;; (awful.key [modkey :Control] "."
  ;;            (fn [c] (focus_by_idx 1 c))
  ;;            {:description "focus next by index" :group :client})
  ;; (awful.key [modkey :Control] ","
  ;;            (fn [c] (focus_by_idx -1 c))
  ;;            {:description "focus prev by index" :group :client})
  (awful.key [modkey :Control] :Return
             (fn [c]
               (c:swap (awful.client.getmaster)))
             {:description "move to master"
              :group :client})
  (awful.key superkey :o (fn [c] (c:move_to_screen))
             {:description "move to screen"
              :group :client})
  (awful.key superkey :f
             (fn [c]
               (set c.fullscreen (not c.fullscreen))
               (c:raise))
             {:description :fullscreen :group :client})
  (awful.key superkey :m
             (fn [c]
               (set c.maximized (not c.maximized))
               (c:raise))
             {:description :maximize :group :client})
  (awful.key superkey "\\"
             (fn [c]
               (set c.maximized_vertical
                    (not c.maximized_vertical))
               (c:raise))
             {:description "maximize vertically"
              :group :client})
  (awful.key superkey "-"
             (fn [c]
               (set c.maximized_horizontal
                    (not c.maximized_horizontal))
               (c:raise))
             {:description "maximize horizontally"
              :group :client})))

(_G.root.keys global_keys)

;; Mouse bindings
(local {: my_main_menu } (require :menu))
(_G.root.buttons
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

{: simulate_key
 : modkey
 : superkey
 : client_keys
 : global_keys
 : my_keyboard_layout
 : client_buttons}
