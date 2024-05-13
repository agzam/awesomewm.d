(local gears (require :gears))
(local awful (require :awful))
(local naughty (require :naughty))
(global {
         : apply
         : complement
         : compose
         : concat
         : conj
         : count
         : drop
         : drop-while
         : empty?
         : filter
         : first
         : flatten
         : get
         : get-in
         : has-some?
         : identity
         : join
         : last
         : map
         : map-kv
         : mapcat
         : merge
         : noop
         : range
         : reduce
         : remove
         : seq
         : seq?
         : some
         : take-while
         } (require :fun))
(global { : lame_dbg } (require :core))

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

(awful.spawn.once "emacs" {:tag (-?> screen (. 1) (. :tags) (. 1))
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
      "brave --force-device-scale-factor=1.1"
      {:stdout (fn [] (let [clnt (-?>> (client.get) (filter (fn [c] (= c.class :Brave-browser))) first)]
                        (when clnt (clnt:move_to_screen "DP-4"))))}))))

(set awful.layout.layouts
     [awful.layout.suit.tile
      awful.layout.suit.fair.horizontal
      awful.layout.suit.floating
      awful.layout.suit.max
      awful.layout.suit.max.fullscreen])

(require :theming)
(require :screen)
(require :keybindings)
(require :rules)
