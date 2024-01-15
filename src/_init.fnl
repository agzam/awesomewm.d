;; Standard awesome library
(local gears (require :gears))
(local awful (require :awful))
(require :awful.autofocus)
(global {
         : apply
         : concat
         : count
         : drop
         : drop-while
         : filter
         : first
         : identity
         : last
         : map
         : mapcat
         : merge
         : remove
         : seq?
         : take-while
         } (require :fun))

;; Notification library
(local naughty (require :naughty))

;;;;;;;;;;;;;;;;;;;;
;; Error handling ;;
;;;;;;;;;;;;;;;;;;;;

;; Check if awesome encountered an error during startup and fell back to
;; another config (This code will only ever execute for the fallback config)
(when _G.awesome.startup_errors
  (naughty.notify {:preset naughty.config.presets.critical
                   :title "Oops, there were errors during startup!"
                   :text _G.awesome.startup_errors}))

;; Handle runtime errors after startup
(var in_error? false)
(_G.awesome.connect_signal
 "debug::error"
 (fn [err]
   ;; Make sure we don't go into an endless error loop
   (when (not in_error?)
     (set in_error? true)
     (naughty.notify {:preset naughty.config.presets.critical
                      :title "Oops, an error happened!"
                      :text (tostring err)})
     (set in_error? false))))

(awful.spawn.with_shell (.. "source " (os.getenv "HOME") "/.xprofile &"))

(awful.spawn.once "emacs" {:tag (-?> _G.screen (. 1) (. :tags) (. 1))
                           :instance :emacs
                           :screen "DP-4"}
                  (fn [c] (= c.class :Emacs)))

;; spawn.once doesn't work for Brave and that makes you do some stupid shit like this. I have to manually check if it's
;; running and then start it, then finally move it to the screen I want it to be
(awful.spawn.easy_async_with_shell
 "if ! pgrep -x 'brave' > /dev/null; then exit 1; fi"
 (fn [_ _ _ exit-code]
   (when (= exit-code 1)
     (awful.spawn.with_line_callback
      "brave"
      {:stdout (fn [] (let [clnt (-?>> (_G.client.get) (filter (fn [c] (= c.class :Brave-browser))) first)]
                        (when clnt (clnt:move_to_screen "DP-4"))))}))))

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
     :text (gears.debug.dump_return obj)
     :run (fn [noti-obj]
            "Wheh clicked, copy notification text to clipboard"
            (let [txt (-?> noti-obj (. :textbox) (. :text))]
              (awful.spawn.with_shell
               (.. "echo '" txt "' | xclip -selection clipboard")))
            (noti-obj.die naughty.notificationClosedReason.dismissedByUser))})))

(require :theming)
(require :screen)
(require :keybindings)
(require :rules)
