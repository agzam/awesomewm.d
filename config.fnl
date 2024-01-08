;; Standard awesome library
(local gears (require :gears))
(local beautiful (require :beautiful))
(local awful (require :awful))
(require :awful.autofocus)

;; Widget and layout library
(local wibox (require :wibox))

;; Notification library
(local naughty (require :naughty))

;;;;;;;;;;;;;;;;;;;;
;; Error handling ;;
;;;;;;;;;;;;;;;;;;;;

;; Check if awesome encountered an error during startup and fell back to
;; another config (This code will only ever execute for the fallback config)
(when awesome.startup_errors
  (naughty.notify {:preset naughty.config.presets.critical
                   :title "Oops, there were errors during startup!"
                   :text awesome.startup_errors}))

;; Handle runtime errors after startup
(do
  (local in-error? false)
  (awesome.connect_signal
   "debug::error"
   (fn [err]
     ;; Make sure we don't go into an endless error loop
     (when (not in_error?)
       (set in_error? true)

       (naughty.notify {:preset naughty.config.presets.critical
                        :title "Oops, an error happened!"
                        :text (tostring err)})
       (set in_error? false)))))

(local wibox (require :wibox))
(global my_text_clock (wibox.widget.textclock))

(local cfg-dir  (.. (os.getenv "HOME") "/.config/awesome/"))
(os.execute "xset r rate 180 100")
(os.execute (.. cfg-dir "xrandr-settings.sh"))

(set terminal "kitty")
(local menubar (require :menubar))
(set menubar.utils.terminal terminal)

(set awful.layout.layouts
     [awful.layout.suit.tile
      awful.layout.suit.tile.left
      awful.layout.suit.fair
      awful.layout.suit.floating
      awful.layout.suit.max
      awful.layout.suit.max.fullscreen])

(local hotkeys_popup (require :awful.hotkeys_popup))

(set my_awesome_menu [["hotkeys" (fn [] (hotkeys_popup.show_help nil (awful.screen.focused)))]
                      ["manual" (.. terminal " -e man awesome")]
                      ;; ["edit config" (.. editor_cmd " " awesome.conffile)]
                      ["restart" awesome.restart]
                      ["quit" (fn [] (awesome.quit))]])

(global my_main_menu (awful.menu {:items [["awesome" my_awesome_menu beautiful.awesome_icon]
                                       ["open terminal" terminal]]}))

(require :theming)
(require :keybindings)
(require :rules)
(require :screen)
