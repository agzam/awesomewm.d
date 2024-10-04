(local awful (require :awful))
(local gears (require :gears))
(local hotkeys_popup (require :awful.hotkeys_popup))
(local menubar (require :menubar))
(local modalawesome (require :modalawesome))
(local {: modkey
        : superkey
        : all-clients
        : map-key
        : simulate-key
        } (require :core))
(local { : edit-with-emacs } (require :emacs))

;; Keyboard map indicator and switcher
(local my-keyboard-layout (awful.widget.keyboardlayout))

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
 global-keys
 (gears.table.join
  (map-key [modkey] :space
           (fn []
             (modalawesome.init
              {:modkey :Mod5
               :default_mode :root-mode
               :modes (require :modes)
               :stop_name "⭐"
               :keybidings {}}))
           "Main modal"
           :awesome)
  (map-key superkey :6 awesome.restart "reload awesome" :awesome)
  (map-key [modkey :Control] :r awesome.restart "reload awesome" :awesome)
  ;; (map-key [modkey] "." (fn [] (awesome.emit_signal "bling::window_switcher::turn_on"))
  ;;          "window switcher" :group :client)


  (map-key [modkey :Control] "."
           (fn [c] (focus-byidx-global 1 c))
           "focus next by index" :client)

  (map-key [modkey :Control] ","
           (fn [c] (focus-byidx-global -1 c))
           "focus prev by index" :client)
  (map-key [modkey :Control] :Left #(awful.layout.inc -1)
           "Layout prev" :layout)
  (map-key [modkey :Control] :Right #(awful.layout.inc 1)
           "Layout next" :layout)
  (map-key [modkey :Control] :o edit-with-emacs
           "edit with Emacs" :client)

  (map-key superkey "s"
           (fn []
             (let [cmd "emacsclient -e '(clipboard->tts)' &"]
               (awful.spawn.with_shell cmd)))
           "selection to TTS" :client)

  ;; copy-paste like on Mac
  (simulate-key [modkey] :a [:Control] :a)
  (simulate-key [modkey] :c [:Control] :c)
  (simulate-key [modkey] :x [:Control] :x)
  (simulate-key [modkey] :v [:Control] :v)

  ;; alt-backspace like on Mac. For some strange reasons, specifically
  ;; Alt_L gets stuck on this one, had to do it this way
  (map-key
   [:Mod1] :BackSpace
   (fn []
     (awful.key.execute [:Control] :BackSpace)
     (gears.timer.weak_start_new
      0.01
      #(root.fake_input :key_release :Alt_L) false)))))

(local
 client-keys
 (gears.table.join
  (map-key [modkey :Control] :Return
           (fn [c]
             (c:swap (awful.client.getmaster)))
           "move to master" :client)
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
           "maximize horizontally" :client)))

(root.keys global-keys)

;; Mouse bindings
(local {: my_main_menu } (require :menu))
(root.buttons
 (gears.table.join
  (awful.button [] 3
                (fn [] (my_main_menu:toggle)))
  (awful.button [] 4 awful.tag.viewnext)
  (awful.button [] 5 awful.tag.viewprev)))

(local
 client-buttons
 (gears.table.join
  (awful.button
   nil 1
   (fn [c]
     (c:emit_signal "request::activate"
                    :mouse_click
                    {:raise true})))
  (awful.button
   [modkey :Mod1] 1 ; Cmd+Alt+LeftClick - move window
   (fn [c]
     (c:emit_signal "request::activate"
                    :mouse_click
                    {:raise true})
     (awful.mouse.client.move c)))
  (awful.button
   [modkey :Mod1] 3 ; Cmd+Alt+RightClick - resize window
   (fn [c]
     (c:emit_signal "request::activate"
                    :mouse_click
                    {:raise true})
     (awful.mouse.client.resize c)))))

{: modkey
 : superkey
 : client-keys
 : global-keys
 : my-keyboard-layout
 : client-buttons}
