(local awful (require :awful))
(local gears (require :gears))
(local { : shellout
         : all-clients} (require :core))

(fn init []
  (awful.spawn.with_shell
   (string.format
    "emacsclient -e '(load-file \"%s\")'"
    (.. cfg_dir "lib/awesome-wm-helpers.el"))))

(fn copy-to-clipboard [cb]
  (let [clb (shellout "xsel -ob")
        pri (shellout "xsel -op")]
    (when (or (= pri clb) (empty? pri))
      (awful.spawn.with_shell
       "xdotool key --clearmodifiers ctrl+a"))
    (awful.spawn.easy_async_with_shell
     "xdotool key --clearmodifiers ctrl+c"
     cb)))

(fn edit-with-emacs []
  (when (and client.focus
             (not= client.focus.class :Emacs))
    (copy-to-clipboard
     (fn []
       (let [cmd (string.format
                  "emacsclient -e '(awesome-edit-with-emacs %s \"%s\")'"
                  client.focus.pid
                  (gears.string.xml_escape
                   client.focus.name))
             emacs-cl (-?>> (all-clients)
                            (filter (fn [c] (= c.class :Emacs)))
                            first)]
         (awful.spawn.with_shell cmd)
         (awful.client.focus.byidx 0 emacs-cl))))))

(fn switch_to_app [pid cb]
  (let [app-cl (-?>> (all-clients)
                     (filter (fn [c] (= c.pid pid)))
                     first)]
    (awful.client.focus.byidx 0 app-cl)
    (when client.focus
      (cb))))

(fn switch_to_client_and_paste [pid]
  (switch_to_app
   pid
   (fn []
     (when client.focus
       (awful.spawn.with_shell "xdotool key ctrl+v")))))

(init)

{
 : edit-with-emacs
 : switch_to_client_and_paste
 : switch_to_app
 }
