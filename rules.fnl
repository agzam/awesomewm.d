(local beautiful (require :beautiful))
(local awful (require :awful))
(local gears (require :gears))
(local wibox (require :wibox))

(set awful.rules.rules
     [;; All clients will match this rule
      {:rule []
       :properties {:useless_gap 10
                    :border_width beautiful.border_width
                    :border_color beautiful.border_normal
                    :focus awful.client.focus.filter
                    :raise true
                    :keys client_keys
                    :buttons client_buttons
                    :screen awful.screen.preferred
                    :placement (+ awful.placement.no_overlap
                                  awful.placement.no_offscreen)}}
      {:rule_any {:instance [:DTA    ; Firefox addon DownThemAll.
                             :copyq  ; Includes session name in class.
                             :pinentry]
                  :class [:Arandr
                          :Blueman-manager
                          :Gpick
                          :Kruler
                          :MessageWin  ; kalarm.
                          :Sxiv
                          :Tor Browser ; Needs a fixed window size to avoid fingerprinting by screen size.
                          :Wpa_gui
                          :veromix
                          :xtightvncviewer]
                  ;; Note that the name property shown in xprop might be set slightly after creation of the client
                  ;; and the name shown there might not match defined rules here.
                  :name ["Event Tester"  ; xev.
                         ]
                  :role [:AlarmWindow    ;  Thunderbird's calendar.
                         :ConfigManager  ; Thunderbird's about:config.
                         :pop-up         ; e.g. Google Chrome's (detached) Developer Tools.
                         ]}
       :properties {:floating true}}

      ;; Add titlebars to normal clients and dialogs
      {:rule_any {:type [:normal :dialog]}
       :properties {:titlebars_enabled true}}])


;; Signal function to execute when a new client appears.
(client.connect_signal
 :manage
 (fn [c]
   ;; Set the windows at the slave,
   ;; i.e. put it at the end of others instead of setting it master.
   ;; if not awesome.startup then awful.client.setslave(c) end
   (when (and awesome.startup
              (not c.size_hints.user_position)
              (not c.size_hints.program_position))
     ;; Prevent clients from being unreachable after screen count changes.
     (awful.placement.no_offscreen c))))

;; Add a titlebar if titlebars_enabled is set to true in the rules.
(client.connect_signal
 "request::titlebars"
 (fn [c]
   ;; buttons for the titlebar
   (let [buttons (gears.table.join
                  (awful.button nil 1 (fn []
                                        (: c :emit_signal
                                         "request::activate"
                                         :titlebar
                                         {:raise true})))

                  (awful.button nil 3 (fn []
                                        (: c :emit_signal
                                         "request::activate"
                                         :titlebar
                                         {:raise true})
                                        (awful.mouse.client.resize c))))]
     (let [left {:1 (awful.titlebar.widget.iconwidget c)
                 :buttons buttons
                 :layout wibox.layout.fixed.horizontal}
           middle {;; title
                   :1 {:align :center
                       :widget (awful.titlebar.widget.titlewidget c)}
                   :buttons buttons
                   :layout  wibox.layout.flex.horizontal}
           right {:1 (awful.titlebar.widget.floatingbutton c)
                  :2 (awful.titlebar.widget.maximizedbutton c)
                  :3 (awful.titlebar.widget.stickybutton c)
                  :4 (awful.titlebar.widget.ontopbutton c)
                  :5 (awful.titlebar.widget.closebutton c)
                  :layout (wibox.layout.fixed.horizontal)}
           titlebar-args {:1 left
                          :2 middle
                          :3 right
                          :layout wibox.layout.align.horizontal}]
       (: (awful.titlebar c) :setup titlebar-args)))))

;; Enable sloppy focus, so that focus follows mouse.
(client.connect_signal
 "mouse::enter"
 (fn [c]
   (: c :emit_signal "request::activate" :mouse_enter {:raise false})))
(client.connect_signal
 :focus
 (fn [c] (set c.border_color beautiful.border_focus)))
(client.connect_signal
 :unfocus
 (fn [c] (set c.border_color beautiful.border_normal)))
