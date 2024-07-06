(local awful (require :awful))
(local hotkeys_popup (require :awful.hotkeys_popup))
(local gears (require :gears))
(local menubar (require :menubar))
(local apps (require :apps))
(local media (require :media))

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

(fn jump-to-tag [abs-idx]
  (let [cur-idx (. (awful.tag.selected) :index)]
    (awful.tag.viewidx (- abs-idx cur-idx))))

(local
 root
 (concat
  [{:description "windows"
    :pattern [:w]
    :handler (fn [mode] (mode.start :windows))}
   {:description "apps"
    :pattern [:a]
    :handler (fn [mode] (mode.start :apps))}
   {:description "media"
    :pattern [:m]
    :handler (fn [mode] (mode.start :media))}
   {:description "prev tag"
    :pattern ["[\\[]"]
    :handler (fn [mode]
               (awful.tag.viewprev)
               (mode.start :tags))}
   {:description "next tag"
    :pattern ["]"]
    :handler (fn [mode]
               (awful.tag.viewnext)
               (mode.start :tags))}
   {:description "move to tag"
    :pattern ["t"]
    :handler (fn [mode] (mode.start :move-to-tag))}
   {:description "enter client mode"
    :pattern [:Escape]
    :handler (fn [mode] (mode.stop))}]

  (fcollect [i 1 (length (. (awful.screen.focused) :tags))]
    {:description (.. "tag" (tostring i))
     :pattern [(tostring i)]
     :handler (fn [mode]
                (jump-to-tag i)
                (mode.stop))})))

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
                      (apps.focus-or-launch c.class)
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
               (apps.focus-or-launch :Emacs)
               (mode.stop))}
   {:description "Browser"
    :pattern [:b]
    :handler (fn [mode]
               (apps.focus-or-launch :Brave-browser)
               (mode.stop))}
   {:description "Terminal"
    :pattern [:i]
    :handler (fn [mode]
               (apps.focus-or-launch :kitty)
               (mode.stop))}
   {:description "YouTube Music Player"
    :pattern [:m]
    :handler (fn [mode]
               (media.activate-ytm-player)
               (mode.stop))}
   {:description "MPV"
    :pattern [:v]
    :handler (fn [mode]
               (apps.focus-or-launch :mpv)
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
      (media.activate-ytm-player))}
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
      (media.ytm-press-key "semicolon"))}
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
      (media.ytm-press-key :j))}
   {:description "prev song"
    :pattern [:h]
    :handler
    (fn [mode]
      (mode.stop)
      (media.ytm-press-key :k))}
   {:description "like song"
    :pattern ["*"]
    :handler
    (fn [mode]
      (mode.stop)
      (media.ytm-press-key "KP_Add"))}
   {:description "hate song"
    :pattern ["#"]
    :handler
    (fn [mode]
      (mode.stop)
      (media.ytm-press-key "minus"))}
   {:description "search"
    :pattern ["/"]
    :handler
    (fn [mode]
      (mode.stop)
      (media.ytm-press-key "slash" :stay))}]
  esc-and-root))

(local
 tags
 (concat
  [{:description "prev tag"
    :pattern ["[\\[]"]
    :handler (fn [_] (awful.tag.viewprev))}
   {:description "next tag"
    :pattern ["]"]
    :handler (fn [_] (awful.tag.viewnext))}]
  esc-and-root))

(fn move-win-to-tag [tag-idx]
  (when (not client.focus)
    (set client.focus (. (. (awful.screen.focused) :clients) 1)))
  (when client.focus
    (let [clnt client.focus
          tag (. client.focus.screen.tags tag-idx)]
      (client.focus:move_to_tag tag)
      (jump-to-tag tag-idx)
      (set client.focus clnt))))

(local
 move-to-tag
 (concat
  (fcollect [i 1 (length (. (awful.screen.focused) :tags))]
    {:description (tostring i)
     :pattern [(tostring i)]
     :handler (fn [mode]
                (move-win-to-tag i)
                (mode.stop))})
  esc-and-root))

{: root
 : windows
 : apps
 : shrink-widen
 : media
 : tags
 : move-to-tag
 }
