(local awful (require :awful))
(local hotkeys_popup (require :awful.hotkeys_popup))
(local gears (require :gears))
(local menubar (require :menubar))
(local {: all-clients} (require :core))

(fn focus-or-launch [app-class window-id]
  (let [cl (-?>> (all-clients)
                 (filter
                  (fn [c]
                    (if window-id
                        (= c.window window-id)
                        (= c.class app-class))))
                 first)
        app-name (if (= app-class "Brave-browser") "Brave" app-class)]
    ;; if we find the matching client, we switch to it,
    ;; otherwise find the app with the same name, and launch it
    (if cl
        (do
          (set cl.minimized false)
          (awful.client.focus.byidx 0 cl))
        (do
          (menubar.refresh)
          (gears.timer.weak_start_new
           0.1
           (fn []
             (let [cmd (. (-?>>
                           menubar.menu_entries
                           (filter (fn [x] (= x.name app-name)))
                           first)
                        :cmdline)]
               (awful.spawn.with_shell cmd)
               false)))))))

(fn ytm-player-app-id [cb]
  (menubar.refresh)
  (gears.timer.weak_start_new
   0.1
   (fn []
     (let [cl (-?> (-?>>
                    menubar.menu_entries
                    (filter (fn [x] (= x.name "YouTube Music")))
                    first)
                   (. :cmdline)
                   (: :match "--app%-id=(%w+)"))]
       (cb cl) false))))

(fn activate-ytm-player []
  (ytm-player-app-id
   (fn [app-id]
     (let [fnd (-?>> (all-clients)
                     (filter
                      (fn [c]
                        (= c.instance (.. "crx_" app-id))))
                     first)]
       (if fnd
           (do
             (set fnd.minimized false)
             (awful.client.focus.byidx 0 fnd))
           (focus-or-launch "YouTube Music"))))))

(fn ytm-press-key [key stay]
  (let [current client.focus]
    (activate-ytm-player)
    (gears.timer.weak_start_new
     0.1
     (fn []
       (awful.spawn.easy_async
        (..
         "xdotool key --clearmodifiers Escape key Escape key i sleep 0.1 key " key)
        (fn []
          (when (not stay)
           (focus-or-launch nil current.window))))
       false))))

(local
 esc-and-root
 [{:description "show help"
   :pattern ["?"]
   :handler (fn [] (hotkeys_popup.show_help))}
  {:description "root"
   :pattern {:Mod4 " "}
   :handler (fn [mode] (mode.start :root))}
  {:description "escape"
   :pattern [:Escape]
   :handler (fn [mode] (mode.stop))}])

(local
 root
 [{:description "windows"
   :pattern [:w]
   :handler (fn [mode] (mode.start :windows))}
  {:description "apps"
   :pattern [:a]
   :handler (fn [mode] (mode.start :apps))}
  {:description "media"
   :pattern [:m]
   :handler (fn [mode] (mode.start :media))}
  {:description "enter client mode"
   :pattern [:Escape]
   :handler (fn [mode] (mode.stop))}])

(local
 shrink-widen
 (concat
  [{:description "widen horizontally"
    :pattern ["]"]
    :handler (fn [_] (awful.tag.incmwfact 0.01))}
   {:description "shrink horizontally"
    :pattern ["[\\[]"]
    :handler (fn [_] (awful.tag.incmwfact -0.01))}]
  esc-and-root))

(local
 windows
 (concat
  [{:description "other window"
    :pattern [:w]
    :handler (fn [mode]
               (awful.client.focus.byidx 1)
               (mode.stop))}
   {:description "left window"
    :pattern [:h]
    :handler (fn [mode]
               (awful.client.focus.global_bydirection :left)
               (mode.stop))}
   {:description "right window"
    :pattern [:l]
    :handler (fn [mode]
               (awful.client.focus.global_bydirection :right)
               (mode.stop))}
   {:description "upper window"
    :pattern [:k]
    :handler (fn [mode]
               (awful.client.focus.global_bydirection :up)
               (mode.stop))}
   {:description "bottom window"
    :pattern [:j]
    :handler (fn [mode]
               (awful.client.focus.global_bydirection :down)
               (mode.stop))}
   {:description "window move left"
    :pattern [:H]
    :handler (fn [mode]
               (awful.client.swap.global_bydirection :left)
               (mode.stop))}
   {:description "window move right"
    :pattern [:L]
    :handler (fn [mode]
               (awful.client.swap.global_bydirection :right)
               (mode.stop))}
   {:description "window move up"
    :pattern [:K]
    :handler (fn [mode]
               (awful.client.swap.global_bydirection :up)
               (mode.stop))}
   {:description "window move down"
    :pattern [:J]
    :handler (fn [mode]
               (awful.client.swap.global_bydirection :down)
               (mode.stop))}
   {:description "move to other screen"
    :pattern [:o]
    :handler (fn [mode]
               (when client.focus
                 (let [c client.focus]
                   (c:move_to_screen)
                   (gears.timer.weak_start_new
                    0.01
                    (fn []
                      (focus-or-launch c.class)
                      false))
                   (mode.stop))))}
   {:description "window minimize"
    :pattern ["-"]
    :handler (fn [mode]
               (let [c client.focus]
                 (set c.minimized (not c.minimized))
                 (mode.stop)))}
   {:description "window maximize"
    :pattern [:m]
    :handler (fn [mode]
               (let [c client.focus]
                 (set c.maximized (not c.maximized))
                 (c:raise)
                 (mode.stop)))}
   {:description "toggle floating"
    :pattern ["`"]
    :handler (fn [mode]
               (let [c client.focus]
                 (set c.floating (not c.floating))
                 (mode.stop)))}
   {:description "fullscreen"
    :pattern [:f]
    :handler (fn [mode]
               (let [c client.focus]
                 (set c.fullscreen (not c.fullscreen))
                 (c:raise)
                 (mode.stop)))}
   {:description "shrink/widen horizontally"
    :pattern ["[]\\[]"]
    :handler (fn [mode] (mode.start :shrink-widen))}]
  esc-and-root))

(local
 apps
 (concat
  [{:description "Emacs"
    :pattern [:e]
    :handler (fn [mode]
               (focus-or-launch :Emacs)
               (mode.stop))}
   {:description "Browser"
    :pattern [:b]
    :handler (fn [mode]
               (focus-or-launch :Brave-browser)
               (mode.stop))}
   {:description "Terminal"
    :pattern [:i]
    :handler (fn [mode]
               (focus-or-launch :kitty)
               (mode.stop))}
   {:description "YouTube Music Player"
    :pattern [:m]
    :handler (fn [mode]
               (activate-ytm-player)
               (mode.stop))}
   {:description "MPV"
    :pattern [:v]
    :handler (fn [mode]
               (focus-or-launch :mpv)
               (mode.stop))}
   {:description "launcher"
    :pattern [:l]
    :handler (fn [mode]
               (menubar.refresh)
               (menubar.show)
               (mode.stop))}
   {:description "launcher other screen"
    :pattern [:L]
    :handler (fn [mode]
               (awful.screen.focus_relative 1)
               (menubar.refresh)
               (menubar.show)
               (mode.stop))}
   {:description "enter client mode"
    :pattern [:Escape]
    :handler (fn [mode] (mode.stop))}]
  esc-and-root))

(local
 media
 (concat
  [{:description "open player app"
    :pattern [:a]
    :handler
    (fn [mode]
      (mode.stop)
      (activate-ytm-player))}
   {:description "mute/unmute"
    :pattern [:m]
    :handler
    (fn [mode]
      (awful.spawn "pactl set-sink-mute @DEFAULT_SINK@ toggle")
      (mode.stop))}
   {:description "play/pause"
    :pattern [:s]
    :handler
    (fn [mode]
      (mode.stop)
      (ytm-press-key "semicolon"))}
   {:description "volume up"
    :pattern [:k]
    :handler
    (fn [_]
      (awful.spawn "pactl set-sink-volume @DEFAULT_SINK@ +10%"))}
   {:description "volume down"
    :pattern [:j]
    :handler
    (fn [_]
      (awful.spawn "pactl set-sink-volume @DEFAULT_SINK@ -10%"))}
   {:description "volume control"
    :pattern ["v"]
    :handler
    (fn [mode]
      (awful.spawn "pavucontrol")
      (mode.stop))}
   {:description "next song"
    :pattern [:l]
    :handler
    (fn [mode]
      (mode.stop)
      (ytm-press-key :j))}
   {:description "prev song"
    :pattern [:h]
    :handler
    (fn [mode]
      (mode.stop)
      (ytm-press-key :k))}
   {:description "like song"
    :pattern ["*"]
    :handler
    (fn [mode]
      (mode.stop)
      (ytm-press-key "KP_Add"))}
   {:description "hate song"
    :pattern ["#"]
    :handler
    (fn [mode]
      (mode.stop)
      (ytm-press-key "minus"))}
   {:description "search"
    :pattern ["/"]
    :handler
    (fn [mode]
      (mode.stop)
      (ytm-press-key "slash" :stay))}]
  esc-and-root))

{: root
 : windows
 : apps
 : shrink-widen
 : media}
