;; Standard awesome library
(local gears (require :gears))
(local awful (require :awful))
(require :awful.autofocus)

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
(var in_error? false)
(awesome.connect_signal
 "debug::error"
 (fn [err]
   ;; Make sure we don't go into an endless error loop
   (when (not in_error?)
     (set in_error? true)
     (naughty.notify {:preset naughty.config.presets.critical
                      :title "Oops, an error happened!"
                      :text (tostring err)})
     (set in_error? false))))

(local cfg-dir (.. (os.getenv :HOME) :/.config/awesome/))
(os.execute "xset r rate 180 100")
(os.execute (.. cfg-dir :xrandr-settings.sh))

(set awful.layout.layouts
     [awful.layout.suit.tile
      awful.layout.suit.fair.horizontal
      awful.layout.suit.floating
      awful.layout.suit.max
      awful.layout.suit.max.fullscreen])

(global
 lame_dbg
 (fn [obj]
   (naughty.notify
    {:title :debug
     :text (gears.debug.dump_return obj)})))

(require :theming)
(require :screen)
(require :keybindings)
(require :rules)
