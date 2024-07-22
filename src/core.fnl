(local awful (require :awful))
(local gears (require :gears))
(local modkey :Mod4)
(local naughty (require :naughty))
(local superkey [modkey :Control :Mod1 :Shift])

(fn all-screens []
  (icollect [_ s (ipairs screen)] (when s s)))

(fn all-clients []
  (let [stacked true]
    (-?>> (all-screens)
          (mapcat (fn [scr] (when scr (scr:get_all_clients stacked)))))))

(fn executable-find [cmd]
  (let [result (io.popen (.. "which " cmd))]
    (if (= (result:read "*a") "")
        (do
          (naughty.notify
            {:preset naughty.config.presets.critical
             :title (string.format "Error: %s not found" cmd)
             :text (string.format "Please install %s and ensure it's in your PATH." cmd)})
          (error (string.format "%s not found in PATH" cmd)))
        true)))

(fn shellout [command]
  (let [f (io.popen command)
        stdout (f:read :*all)]
    (and (f:close) stdout)))

(fn lame_dbg [obj]
  (let [txt (match (type obj)
              :string obj
              :table (gears.debug.dump_return obj)
              _ (tostring obj))]
   (naughty.notify
    {:title :debug
     :text txt
     :run (fn [noti-obj]
            "Wheh clicked, copy notification text to clipboard"
            (let [txt (-?> noti-obj (. :textbox) (. :text))]
              (awful.spawn.with_shell
               (.. "echo '" txt "' | xsel -i -b")))
            (noti-obj.die naughty.notificationClosedReason.dismissedByUser))})))

(fn release-keys
  [...]
  "Unpress multiple keys"
  (let [keys [...]]
    (each [_ k (pairs (table.unpack keys))]
      (when k (root.fake_input :key_release k)))))

(fn simulate-key
  [src-mods src-key dest-mods dest-key]
  "Registers a key that listens for source key (with modifiers) and emits target keypress.
To be used for 'faking' input, when you need to rebind one keybinding to another."
  (awful.key
   src-mods src-key
   (fn []
     (root.fake_input :key_release src-key)
     (when (seq? src-mods)
       (each [_ mkey (ipairs src-mods)]
         (root.fake_input :key_release mkey)))
     (awful.key.execute dest-mods dest-key))))

(fn map-key [mods key f desc group]
  "Specialized version of `awful.key`"
  (awful.key
   mods key
   (fn [...]
     (release-keys (concat mods [key]))
     (f ...))
   {:description desc :group group}))

{
 : all-clients
 : all-screens
 : lame_dbg
 : map-key
 : modkey
 : release-keys
 : shellout
 : simulate-key
 : superkey
 : executable-find
 }
