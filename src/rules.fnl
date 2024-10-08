(local beautiful (require :beautiful))
(local awful (require :awful))
(local gears (require :gears))
(local wibox (require :wibox))
(local keybindings (require :keybindings))
(local {:merge merge} (require :fun))
(local browser (require :browser))
(local media (require :media))

(set awful.rules.rules
     [{:rule [] ; All clients will match this rule
       :properties {:useless_gap 10
                    :border_width beautiful.border_width
                    :border_color beautiful.border_normal
                    :focus awful.client.focus.filter
                    :raise true
                    :keys keybindings.client-keys
                    :buttons keybindings.client-buttons
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
                          :Wpa_gui
                          :veromix
                          :xtightvncviewer
                          :vlc]
                  ;; Note that the name property shown in xprop might
                  ;; be set slightly after creation of the client and
                  ;; the name shown there might not match defined
                  ;; rules here.
                  :name ["Event Tester"  ; xev.
                         ]
                  :role [:AlarmWindow    ;  Thunderbird's calendar.
                         :ConfigManager  ; Thunderbird's about:config.
                         :pop-up         ; e.g. Google Chrome's (detached) Developer Tools.
                         ]}
       :properties {:floating true}}

      ;; Add titlebars to normal clients and dialogs
      {:rule_any {:type [:normal :dialog]}
       :properties {:titlebars_enabled true}}

      (table.unpack browser.rules)
      (table.unpack media.rules)])

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; persist window geometry for floating windows ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(var floating-geometries {})

(client.connect_signal
 :property::floating_geometry
 (fn [c]
   (when c.class
     (set floating-geometries
          (merge floating-geometries {c.class (c:geometry)})))))

(client.connect_signal
 :manage
 (fn [c]
   (set floating-geometries (table.load :geometries))
   (let [g (get floating-geometries c.class)]
     (when g (c:geometry g)))))

(client.connect_signal
 :unmanage
 (fn [_] (table.save floating-geometries "geometries")))

;; end - persist window geometry for floating windows

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
                                        (c:emit_signal
                                         "request::activate"
                                         :titlebar
                                         {:raise true})))
                  (awful.button nil 3 (fn []
                                        (c:emit_signal
                                         "request::activate"
                                         :titlebar
                                         {:raise true})
                                        (awful.mouse.client.resize c))))
         left (merge [(awful.titlebar.widget.iconwidget c)]
                     {:buttons buttons
                      :layout wibox.layout.fixed.horizontal})
         middle (merge [{:align :center
                         :widget (merge (awful.titlebar.widget.titlewidget c)
                                        {:font "hermit 7"})}]
                       {:buttons buttons
                        :layout wibox.layout.flex.horizontal})
         right (merge
                [(awful.titlebar.widget.floatingbutton c)
                 (awful.titlebar.widget.stickybutton c)
                 (awful.titlebar.widget.ontopbutton c)
                 (awful.titlebar.widget.minimizebutton c)
                 (awful.titlebar.widget.maximizedbutton c)
                 (awful.titlebar.widget.closebutton c)]
                {:layout (wibox.layout.fixed.horizontal)})
         titlebar-args (merge [left middle right]
                              {:layout wibox.layout.align.horizontal})]
     (: (awful.titlebar c {:size 20}) :setup titlebar-args))))

;; Enable sloppy focus, so that focus follows mouse.
(client.connect_signal
 "mouse::enter"
 (fn [c]
   (c:emit_signal
    "request::activate"
    :mouse_enter {:raise false})))

(client.connect_signal
 :focus
 (fn [c]
   (set c.border_color beautiful.border_color_active)))

(client.connect_signal
 :unfocus
 (fn [c]
   (set c.border_color beautiful.border_color_normal)))

(local browser (require :browser))

(local
 app_local_keys
 [browser.browser-local-keys])

(client.connect_signal
 :manage
 (fn [c]
   (each [_ ks (pairs app_local_keys)]
     (when (= c.class ks.app_local_class)
       (let [keys (merge c.keys ks)]
         (tset c :keys keys))))))
