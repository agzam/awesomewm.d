(local gears (require :gears))
(local beautiful (require :beautiful))
(local awful (require :awful))

(local
 my_theme
 ((loadfile (.. (gears.filesystem.get_themes_dir) "zenburn/theme.lua"))))

(local {:apply_dpi dpi} (require "beautiful.xresources"))

(set my_theme.useless_gap (dpi 3))
(set my_theme.wallpaper "/usr/share/backgrounds/manjaro/ostpv1-l.png")

(beautiful.init my_theme)

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
