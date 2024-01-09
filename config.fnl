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

(local cfg-dir  (.. (os.getenv "HOME") "/.config/awesome/"))
(os.execute "xset r rate 180 100")
(os.execute (.. cfg-dir "xrandr-settings.sh"))

(set terminal "kitty")
(local menubar (require :menubar))
(set menubar.utils.terminal terminal)

(set awful.layout.layouts
     [awful.layout.suit.tile
      awful.layout.suit.fair.horizontal
      awful.layout.suit.floating
      awful.layout.suit.max
      awful.layout.suit.max.fullscreen])

(local hotkeys_popup (require :awful.hotkeys_popup))

(fn quit []
  (let [confirm-dlg (awful.menu {:items [[:cancel (fn [] nil)]
                                         [:quit (fn [] (awesome.quit))]]})]
    (: confirm-dlg :show)))

(set my_awesome_menu [["hotkeys" (fn [] (hotkeys_popup.show_help nil (awful.screen.focused)))]
                      ["manual" (.. terminal " -e man awesome")]
                      ;; ["edit config" (.. editor_cmd " " awesome.conffile)]
                      ["restart" awesome.restart]
                      ["run"
                       (fn []
                         (-?> (awful.screen.focused)
                              (. :my_promptbox)
                              (: :run)))]
                      ["quit" quit]])

(global my_main_menu (awful.menu {:items my_awesome_menu}))

(local naughty (require :naughty))

(global
 lame_dbg
 (fn [obj]
   (naughty.notify {:title "debug"
                    :text (gears.debug.dump_return obj)})))

(require :theming)
(require :screen)
(require :keybindings)
(require :rules)
