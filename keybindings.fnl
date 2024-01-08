(local awful (require :awful))
(local gears (require :gears))
(local hotkeys_popup (require "awful.hotkeys_popup"))
;; (require "awful.hotkeys_popup.keys")

(global modkey "Mod4")

;; Keyboard map indicator and switcher
(global my_keyboard_layout (awful.widget.keyboardlayout))

(global global_keys
        (gears.table.join
         (awful.key
          [modkey] :s hotkeys_popup.show_help
          {:description "this help" :group :awesome})
         (awful.key
          [modkey :Control] :r awesome.restart
          {:description "reload awesome" :group :awesome})
         ))

(global client_keys
        (gears.table.join
         (awful.key
          [modkey :Control] :Return
          (fn [client] (: client :swap (awful.client.getmaster))))))

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
