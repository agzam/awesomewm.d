(local awful (require :awful))
(local gears (require :gears))
(local hotkeys_popup (require "awful.hotkeys_popup"))
;; (require "awful.hotkeys_popup.keys")

(global modkey "Mod4")
(global superkey [modkey :Control :Mod1 :Shift])

;; Keyboard map indicator and switcher
(global my_keyboard_layout (awful.widget.keyboardlayout))

(global
 global_keys
 (gears.table.join
  (awful.key
   superkey :s hotkeys_popup.show_help
   {:description "this help" :group :awesome})
  (awful.key
   superkey :r awesome.restart
   {:description "reload awesome" :group :awesome})

  (awful.key
   [modkey :Control] "."
   (fn [] (awful.client.focus.byidx 1))
   {:description "focus next by index"
    :group :client})

  (awful.key
   [modkey :Control] ","
   (fn [] (awful.client.focus.byidx -1))
   {:description "focus next by index"
    :group :client})

  (awful.key
   [modkey :Control] ","
   (fn [] (awful.client.focus.byidx -1))
   {:description "focus next by index"
    :group :client})

  (awful.key
   [modkey] "."
   (fn [c]
     (awful.client.focus.byidx 1)
     (when client.focus
       (awful.client.setmaster client.focus)))
   {:description "next to master"
    :group :client})

  (awful.key
   [modkey] ","
   (fn [c]
     (awful.client.focus.history.previous)
     (when client.focus
       (awful.client.setmaster client.focus)))
   {:description "prev to master"
    :group :client})

  (awful.key
   superkey "1" (fn [] (awful.client.run_or_raise
                        "brave"
                        (fn [c] (awful.rules.match c {:class "Brave-browser"}))))
   {:description "jump to Brave"
    :group :launcher})

  (awful.key
   superkey "2"
   (fn [] (awful.client.run_or_raise
           "emacs"
           (fn [c] (awful.rules.match c {:class "Emacs"}))))
   {:description "jump to Emacs"
    :group :launcher})

  (awful.key
   superkey "3"
   (fn [] (awful.client.run_or_raise
           "kitty"
           (fn [c] (awful.rules.match c {:class "kitty"}))))
   {:description "jump to Kitty"
    :group :launcher})

  (awful.key [modkey] "l"
             (fn []
               (awful.tag.incmwfact 0.05)
               )
             {:description "increase master width factor" :group "layout"})))

(global
 client_keys
 (gears.table.join
  (awful.key
   [modkey :Control] "Return"
   (fn [c] (: c :swap (awful.client.getmaster)))
   {:description "move to master"
    :group "client"})))

(root.keys global_keys)


;; Mouse bindings
(root.buttons
 (gears.table.join
  (awful.button [] 3 (fn [] (: my_main_menu :toggle)))
  (awful.button [] 4 awful.tag.viewnext)
  (awful.button [] 5 awful.tag.viewprev)))


(global
 client_buttons
 (gears.table.join
  (awful.button
   [] 1 (fn [c] (c:emit_signal "request::activate" :mouse_click {:raise true})))
  (awful.button
   [modkey] 1 (fn [c]
                (c:emit_signal "request::activate" :mouse_click {:raise true})
                (awful.mouse.client.move c)))
  (awful.button
   [modkey] 3 (fn [c]
                (c:emit_signal "request::activate" :mouse_click {:raise true})
                (awful.mouse.client.resize c)))))
