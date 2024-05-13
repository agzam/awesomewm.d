(local gears (require :gears))
(local beautiful (require :beautiful))
(local awful (require :awful))
(local {: merge} (require :fun))

(local {:apply_dpi dpi} (require "beautiful.xresources"))

(let [theme (-> ((loadfile (.. (gears.filesystem.get_themes_dir) "zenburn/theme.lua")))
             (merge {:font "hermit 10"
                     :useless_gap (dpi 6)
                     :border_width (dpi 3)
                     :border_focus "#fcba03"
                     :bg_normal "#000"
                     :wallpaper (fn [s]
                                  (let [wps ["wallpaper_wide.png"
                                             "wallpaper_portrait.png"]]
                                    (-?>> (. wps s.index)
                                         (.. "/home/ag/Pictures/"))))}))]
  (beautiful.init theme))

(fn set_wallpaper [s]
  (when beautiful.wallpaper
    (let [wp beautiful.wallpaper
          wallpaper (if (= (type wp) "function")
                        (wp s)
                        wp)]
      (gears.wallpaper.fit wallpaper s false))))

;; Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
(screen.connect_signal "property::geometry" set_wallpaper)

(awful.screen.connect_for_each_screen
 (fn [s] (set_wallpaper s)))
