(local gears (require :gears))
(local awful (require :awful))
(local wibox (require :wibox))
(local beautiful (require :beautiful))
(local {:my_keyboard_layout my_keyboard_layout} (require :keybindings))

;; Create a wibox for each screen and add it
(local
 taglist_buttons
 (gears.table.join
  (awful.button nil 1 (fn [tag] (: tag :view_only)))
  (awful.button [modkey] 1 (fn [tag] (when client.focus
                                       (: client.focus :move_to_tag tag))))
  (awful.button nil 3 awful.tag.viewtoggle)
  (awful.button [modkey] 3 (fn [tag] (when client.focus
                                       (: client.focus :toggle_tag tag))))
  (awful.button nil 4 (fn [tag] (awful.tag.viewnext tag.screen)))
  (awful.button nil 5 (fn [tag] (awful.tag.viewprev tag.screen)))))

(local
 tasklist_buttons
 (gears.table.join
  (awful.button nil 1 (fn [c]
                        (if (= c client.focus)
                            (set c.minimized true)
                            (: c :emit_signal
                             "request::activate"
                             :tasklist
                             {:raise true}))))
  (awful.button nil 3 (fn [] (awful.menu.client_list {:theme {:width 250}})))
  (awful.button nil 4 (fn [] (awful.client.focus.byidx 1)))
  (awful.button nil 5 (fn [] (awful.client.focus.byidx -1)))))

(local my_launcher (awful.widget.launcher {:image beautiful.awesome_icon
                                           :menu my_main_menu}))

(local my_text_clock (wibox.widget.textclock))

(awful.screen.connect_for_each_screen
 (fn [scr]
   ;; Each screen has its own tag table.
   (let [def-layout (case scr.index
                      1 (. awful.layout.layouts 1)
                      2 (. awful.layout.layouts 2))]
     (awful.tag
      [:1 :2 :3 :4]
      scr def-layout))

   ;; Create a promptbox for each screen
   (set scr.my_promptbox (awful.widget.prompt))

   ;; Create an imagebox widget which will contain an icon indicating which layout we're using.
   ;; We need one layoutbox per screen.
   (set scr.my_layoutbox (awful.widget.layoutbox scr))
   (: scr.my_layoutbox :buttons
      (gears.table.join
       (awful.button nil 1 (fn [] (awful.layout.inc 1)))
       (awful.button nil 3 (fn [] (awful.layout.inc -1)))
       (awful.button nil 4 (fn [] (awful.layout.inc 1)))
       (awful.button nil 5 (fn [] (awful.layout.inc -1)))))

   ;; Create a taglist widget
   (set scr.my_taglist (awful.widget.taglist {:screen scr
                                              :filter  awful.widget.taglist.filter.all
                                              :buttons taglist_buttons}))

   (set scr.my_tasklist (awful.widget.tasklist {:screen scr
                                                :filter awful.widget.tasklist.filter.currenttags
                                                :buttons tasklist_buttons}))

   ;; Create the wibox
   (set scr.my_wibox (awful.wibar {:position :top :screen scr}))

   ;; Add widgets to the wibox
   (let [left (gears.table.join
               {:layout wibox.layout.fixed.horizontal}
               [my_launcher]
               [scr.my_taglist]
               [scr.my_promptbox])
         right (gears.table.join
                {:layout wibox.layout.fixed.horizontal}
                [my_keyboard_layout]
                [(wibox.widget.systray)]
                [my_text_clock]
                [scr.my_layoutbox])
         args (gears.table.join
               {:layout wibox.layout.align.horizontal}
               [left]
               [scr.my_tasklist]
               [right])]
     (: scr.my_wibox :setup args))))

(awful.screen.connect_for_each_screen
 (fn [scr]
   (case scr.index
     1 (set scr.selected_tag.column_count 4)
     2 (set scr.selected_tag.column_count 1))))