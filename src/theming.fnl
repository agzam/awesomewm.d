(local gears (require :gears))
(local beautiful (require :beautiful))
(local awful (require :awful))
(local {: merge} (require :functional))

(local {:apply_dpi dpi} (require "beautiful.xresources"))

(let [theme (-> ((loadfile (.. (gears.filesystem.get_themes_dir) "zenburn/theme.lua")))
             (merge {:font "hermit 8"
                     :useless_gap (dpi 4)
                     :border_width (dpi 1)
                     :border_focus "#fcba03"
                     :wallpaper "/usr/share/backgrounds/manjaro/ostpv3-l.png"}))]
  (beautiful.init theme))

(fn set_wallpaper [s]
  (when beautiful.wallpaper
    (let [wp beautiful.wallpaper
          wallpaper (if (= (type wp) "function")
                        (wp s)
                        wp)]
      (gears.wallpaper.maximized wallpaper s false))))

;; Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
(screen.connect_signal "property::geometry" set_wallpaper)

(awful.screen.connect_for_each_screen
 (fn [s] (set_wallpaper s)))
